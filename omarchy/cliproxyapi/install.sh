#!/usr/bin/env bash
# Installs the local CLIProxyAPI Claude pool. Idempotent; never overwrites an
# existing config or key file, and never prints secrets.
set -euo pipefail

VERSION=${CLIPROXY_VERSION:-v8.0.51}
HUB_DIR="$HOME/cliproxyapi"
CONFIG="$HUB_DIR/config.yaml"
KEYS="$HUB_DIR/.keys"
AUTH_DIR="$HOME/.cli-proxy-api"
CLAUDE_SETTINGS="$HOME/.claude/settings.json"

script_dir=$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)
tpl="$script_dir/config.yaml.tpl"

step() { printf '\n\033[1m==> %s\033[0m\n' "$*"; }

case "$(uname -m)" in
  x86_64) arch=amd64 ;;
  aarch64 | arm64) arch=aarch64 ;;
  *) echo "unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac

step "CLIProxyAPI binary"
mkdir -p "$HUB_DIR" "$AUTH_DIR"
chmod 700 "$AUTH_DIR"
if [[ ! -x $HUB_DIR/cli-proxy-api ]]; then
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT
  asset="CLIProxyAPI_${VERSION#v}_linux_${arch}.tar.gz"
  base="https://github.com/router-for-me/CLIProxyAPI/releases/download/$VERSION"
  curl -fsSL "$base/$asset" -o "$tmp/$asset"
  curl -fsSL "$base/checksums.txt" -o "$tmp/checksums.txt"
  expected=$(awk -v a="$asset" '$2 == a { print $1 }' "$tmp/checksums.txt")
  actual=$(sha256sum "$tmp/$asset" | awk '{ print $1 }')
  if [[ -z $expected || $expected != "$actual" ]]; then
    echo "checksum verification failed for $asset" >&2
    exit 1
  fi
  tar -xzf "$tmp/$asset" -C "$HUB_DIR"
  chmod 755 "$HUB_DIR/cli-proxy-api"
  echo "installed $VERSION ($arch)"
else
  echo "already installed in $HUB_DIR"
fi

step "Keys"
if [[ ! -f $KEYS ]]; then
  umask 077
  {
    printf 'ACCESS_KEY=sk-%s\n' "$(openssl rand -hex 24)"
    printf 'MANAGEMENT_KEY=%s\n' "$(openssl rand -hex 24)"
  } >"$KEYS"
  echo "generated $KEYS"
else
  echo "keeping existing $KEYS"
fi
chmod 600 "$KEYS"
access_key=$(sed -n 's/^ACCESS_KEY=//p' "$KEYS")
management_key=$(sed -n 's/^MANAGEMENT_KEY=//p' "$KEYS")
if [[ -z $access_key || -z $management_key ]]; then
  echo "$KEYS is missing ACCESS_KEY or MANAGEMENT_KEY" >&2
  exit 1
fi

step "Config"
if [[ ! -f $CONFIG ]]; then
  ACCESS_KEY="$access_key" MANAGEMENT_KEY="$management_key" \
    python3 - "$tpl" "$CONFIG" <<'PY'
import os
import sys

template, destination = sys.argv[1], sys.argv[2]
text = open(template).read()
text = text.replace("__ACCESS_KEY__", os.environ["ACCESS_KEY"])
text = text.replace("__MANAGEMENT_KEY__", os.environ["MANAGEMENT_KEY"])
open(destination, "w").write(text)
PY
  echo "rendered $CONFIG"
else
  echo "keeping existing $CONFIG"
fi
chmod 600 "$CONFIG"

step "Claude settings"
if command -v claude >/dev/null; then
  HUB_ACCESS_KEY="$access_key" python3 - "$CLAUDE_SETTINGS" <<'PY'
import json
import os
import pathlib
import shutil
import sys
import time

path = pathlib.Path(sys.argv[1])
path.parent.mkdir(parents=True, exist_ok=True)
data = json.loads(path.read_text()) if path.exists() else {}
env = data.setdefault("env", {})
wanted = {
    "ANTHROPIC_BASE_URL": "http://127.0.0.1:8317",
    "ANTHROPIC_AUTH_TOKEN": os.environ["HUB_ACCESS_KEY"],
    "ANTHROPIC_API_KEY": "",
}
if all(env.get(k) == v for k, v in wanted.items()) and data.get("promptCacheTtl") == "1h":
    print(f"already points at the hub: {path}")
    raise SystemExit

if path.exists():
    shutil.copy2(path, path.with_name(path.name + ".bak-" + time.strftime("%Y%m%d-%H%M%S")))
env.update(wanted)
data["env"] = env
data["promptCacheTtl"] = "1h"
path.write_text(json.dumps(data, indent=2) + "\n")
os.chmod(path, 0o600)
print(f"pointed at the hub: {path}")
PY
else
  echo "claude not on PATH; skipped $CLAUDE_SETTINGS"
fi

step "Services"
systemctl --user daemon-reload
systemctl --user enable cliproxyapi.service cliproxy-pool-tuner.timer >/dev/null
systemctl --user start cliproxyapi.service cliproxy-pool-tuner.timer
loginctl enable-linger "$USER" 2>/dev/null || true

step "Claude accounts"
count=$(find "$AUTH_DIR" -maxdepth 1 -name 'claude-*.json' 2>/dev/null | wc -l)
if (( count == 0 )); then
  echo "no Claude accounts yet. Run: $HUB_DIR/cli-proxy-api --claude-login"
else
  echo "$count Claude account(s) already signed in under $AUTH_DIR"
fi

echo
echo "Hub:       http://127.0.0.1:8317"
echo "Keys:      $KEYS (mode 600)"
echo "Config:    $CONFIG"
echo "Logs:      journalctl --user -u cliproxyapi -f"
