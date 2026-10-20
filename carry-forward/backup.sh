#!/usr/bin/env bash
# Packs the hand-made state that bootstrap.sh can't reinstall. Contains SSH and AWS keys: keep it off the cloud.
# Restore on the new machine: tar -xzf <file> -C ~
set -euo pipefail
cd "$HOME"
out=${1:-"$HOME/carry-forward-$(date +%Y%m%d).tar.gz"}

PATHS=(
  .ssh .gitconfig .config/git .npmrc .aws
  .config/fish/config.fish .config/fish/fish_plugins .config/fish/fish_variables .config/fish/functions/yayf.fish
  .config/ghostty .config/zed .config/lazygit .config/btop .config/starship.toml .config/mimeapps.list
  .config/systemd/user .config/timewall .config/macos-dynamic-wallpaper .config/typeaside
  .config/niri .config/noctalia
  .claude/CLAUDE.md .claude/settings.json .codex/AGENTS.md .codex/config.toml
)

# Own scripts and binaries in ~/.local/bin; symlinks there belong to installers bootstrap.sh reruns.
mapfile -t BINS < <(find .local/bin -maxdepth 1 -type f ! -name '*.pyc')

existing=()
for p in "${PATHS[@]}" "${BINS[@]}"; do [ -e "$p" ] && existing+=("$p") || echo "skip (missing): $p" >&2; done

umask 077
tar -czf "$out" "${existing[@]}"
echo "$out ($(du -h "$out" | cut -f1), ${#existing[@]} entries)"
