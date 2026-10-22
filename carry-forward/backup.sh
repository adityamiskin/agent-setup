#!/usr/bin/env bash
# Packs the hand-made state that bootstrap.sh can't reinstall. Contains SSH and AWS keys: keep it off the cloud.
# Restore on the new machine: tar -xzf <file> -C ~
set -euo pipefail
cd "$HOME"
out=${1:-"$HOME/carry-forward-$(date +%Y%m%d).tar.gz"}

PATHS=(
  .ssh .gitconfig .config/git .npmrc .aws
  .config/fish/config.fish .config/fish/fish_plugins .config/fish/fish_variables
  .config/zed .config/starship.toml .config/omarchy/backgrounds
  .config/systemd/user .config/typeaside
  .claude/CLAUDE.md .claude/settings.json .codex/AGENTS.md .codex/config.toml
)

# Own scripts and binaries in ~/.local/bin; symlinks belong to installers bootstrap.sh reruns, mise wrappers to Omarchy.
mapfile -t BINS < <(find .local/bin -maxdepth 1 -type f ! -name '*.pyc' -exec grep -L 'exec mise x' {} +)

existing=()
for p in "${PATHS[@]}" "${BINS[@]}"; do [ -e "$p" ] && existing+=("$p") || echo "skip (missing): $p" >&2; done

umask 077
tar -czf "$out" "${existing[@]}"
echo "$out ($(du -h "$out" | cut -f1), ${#existing[@]} entries)"
