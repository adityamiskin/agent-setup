#!/usr/bin/env bash
# Layers Aditya's Omarchy customizations onto a stock Omarchy 4 install. Safe to re-run.
set -euo pipefail

repo_dir=$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)

PKG_DROP=(
  foot chromium evince mpv mpv-mpris nautilus nautilus-python sushi aether cliamp
  libreoffice-fresh kdenlive obs-studio pinta xournalpp obsidian
)
PKG_ADD=(
  strata papers matugen asusctl omazed inter-font
  gst-libav gst-plugins-good gst-plugins-bad gst-plugins-ugly libdvdcss libaacs
)
AUR_ADD=(hyprmoncfg-bin typeaside-bin)
declare -A PLUGINS=(
  [adityamiskin.wallpaper-colors]=https://github.com/adityamiskin/omarchy-wallpaper-colors
  [aditya.workspace-icons]=https://github.com/adityamiskin/omarchy-workspace-icons
  [crmne.hyprmoncfg]=https://github.com/crmne/omarchy-hyprmoncfg
  [evindor.keystroke]=https://github.com/evindor/keystroke
  [io.github.simonschubert.omalauncher]=https://github.com/SimonSchubert/omalauncher-omarchy-plugin
  [lgse.sandman]=https://github.com/lgse/sandman
  [meviusisback.hw-monitor]=https://github.com/meviusisback/omarchy-hw-monitor
  [omaplug]=https://github.com/fross100/omaplug
)

step() { printf '\n\033[1m==> %s\033[0m\n' "$*"; }

step "Packages"
omarchy-pkg-add "${PKG_ADD[@]}"
# Papers ships as a dependency, so dropping Nautilus would take it along.
sudo pacman -D --asexplicit papers >/dev/null
omarchy-pkg-aur-add "${AUR_ADD[@]}"
omarchy-pkg-drop "${PKG_DROP[@]}"
omarchy-webapp-remove-all

step "Locale"
# config.fish exports en_IN.UTF-8.
if ! locale -a | grep -qx 'en_IN.utf8'; then
  sudo sed -i 's/^#en_IN UTF-8/en_IN UTF-8/' /etc/locale.gen
  sudo locale-gen
fi

step "Shell plugins"
installed=$(omarchy-plugin-list)
for id in "${!PLUGINS[@]}"; do
  grep -q "^$id " <<<"$installed" || omarchy-plugin-add "${PLUGINS[$id]}" --enable --yes
done

step "Config files"
# Copied rather than linked: Omarchy, hyprmoncfg and the Strata installer rewrite these in place.
stamp=$(date +%s)
while IFS= read -r -d '' src; do
  rel=${src#"$repo_dir/home/"}
  dest="$HOME/$rel"
  cmp -s "$src" "$dest" && continue
  mkdir -p "$(dirname "$dest")"
  [[ -e $dest ]] && cp "$dest" "$dest.bak.$stamp" && echo "Backed up $dest"
  cp "$src" "$dest"
  echo "Wrote $dest"
done < <(find "$repo_dir/home" -type f -print0)
update-desktop-database "$HOME/.local/share/applications"

step "OpenCode theme"
# Omarchy renders opencode.json.tpl into the active theme on every theme change;
# the symlink makes it visible to OpenCode as the "omarchy" theme.
mkdir -p "$HOME/.config/opencode/themes"
ln -sfn "$HOME/.local/state/omarchy/current/theme/opencode.json" "$HOME/.config/opencode/themes/omarchy.json"
# Render it once for the current theme so the link resolves before the next switch.
if [[ -f $HOME/.local/state/omarchy/current/theme/colors.toml ]]; then
  staging="$HOME/.local/state/omarchy/current/next-theme"
  rm -rf "$staging"
  mkdir -p "$staging"
  cp "$HOME/.local/state/omarchy/current/theme/colors.toml" "$staging/colors.toml"
  if omarchy-theme-set-templates && [[ -f $staging/opencode.json ]]; then
    cp "$staging/opencode.json" "$HOME/.local/state/omarchy/current/theme/opencode.json"
  fi
  rm -rf "$staging"
fi

step "Apps and theme"
omazed setup
if command -v asusctl >/dev/null; then
  asusctl aura effect static -c c4e4ff
  asusctl leds set med
  asusctl slash set --enable --mode Flow -l 110 --interval 1 -b false -w true
fi

hyprctl reload >/dev/null
omarchy-restart-shell >/dev/null 2>&1 || true
echo "Omarchy customizations applied."
