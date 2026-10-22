#!/usr/bin/env bash
# Fresh Omarchy install -> Aditya's dev setup. Skips everything Omarchy already ships.
# Safe to re-run: every step skips what is already there.
set -euo pipefail

PACMAN=(
  github-cli git-delta openssh
  fish ripgrep-all dust duf procs bottom
  hyperfine tokei xh yq aria2 wget rsync pv ncdu vim
  7zip unrar ouch
  uv python jdk-openjdk android-tools
  ghostty zed tailscale qemu-desktop edk2-ovmf
  ttf-fira-code ttf-meslo-nerd
  vlc vlc-plugins-all
  steam flatpak
)
AUR=(
  google-chrome slack-desktop vesktop otf-apple-sf-pro
  typeaside-bin
)
RUST_TARGETS=(aarch64-apple-darwin x86_64-pc-windows-msvc)
BUN_GLOBALS=(convex wrangler)
FISHER_PLUGINS=(ilancosman/tide@v6 patrickf1/fzf.fish jorgebucaran/autopair.fish meaningful-ooo/sponge)

step() { printf '\n\033[1m==> %s\033[0m\n' "$*"; }
has() { command -v "$1" >/dev/null 2>&1; }
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.bun/bin:$HOME/.vite-plus/bin:$HOME/.fly/bin:$PATH"

step "pacman packages"
sudo pacman -Syu --needed --noconfirm "${PACMAN[@]}"

step "AUR packages"
yay -S --needed --noconfirm "${AUR[@]}"

step "GeForce NOW"
if ! flatpak info --user com.nvidia.geforcenow >/dev/null 2>&1; then
  flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  flatpak remote-add --user --if-not-exists GeForceNOW https://international.download.nvidia.com/GFNLinux/flatpak/geforcenow.flatpakrepo
  flatpak install --user --noninteractive GeForceNOW com.nvidia.geforcenow
fi

step "Rust"
has rustup || curl -fsSL https://sh.rustup.rs | sh -s -- -y --no-modify-path
rustup default stable
rustup component add clippy rustfmt
rustup target add "${RUST_TARGETS[@]}"

step "Bun"
has bun || curl -fsSL https://bun.sh/install | bash
bun add -g "${BUN_GLOBALS[@]}"

step "Node via Vite+"
has vp || curl -fsSL https://vite.plus | bash
npm config set prefix "$HOME/.local"

step "Cloud CLIs"
has fly || curl -fsSL https://fly.io/install.sh | sh
if ! has aws; then
  tmp=$(mktemp -d)
  curl -fsSL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o "$tmp/aws.zip"
  unzip -q "$tmp/aws.zip" -d "$tmp"
  "$tmp/aws/install" -i "$HOME/.local/aws-cli" -b "$HOME/.local/bin"
fi
has cloudflared || {
  curl -fsSL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o "$HOME/.local/bin/cloudflared"
  chmod +x "$HOME/.local/bin/cloudflared"
}

step "Fish + plugins"
[ "$(getent passwd "$USER" | cut -d: -f7)" = /usr/bin/fish ] || chsh -s /usr/bin/fish
fish -c 'type -q fisher || begin; curl -fsSL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source; fisher install jorgebucaran/fisher; end'
fish -c "fisher install ${FISHER_PLUGINS[*]}"

step "Agent setup (skills, AGENTS.md)"
[ -d "$HOME/agent-setup" ] || gh repo clone adityamiskin/agent-setup "$HOME/agent-setup" || true
[ -x "$HOME/agent-setup/setup.sh" ] && "$HOME/agent-setup/setup.sh"

step "Omarchy customizations"
[ -x "$HOME/agent-setup/omarchy/apply.sh" ] && "$HOME/agent-setup/omarchy/apply.sh"

step "Done. Manual follow-ups"
cat <<'EOF'
  gh auth login            # git credentials go through gh
  tailscale up
  claude / codex / opencode / pi  # log in to each
  tar -xzf carry-forward-*.tar.gz -C ~ && systemctl --user daemon-reload
EOF
