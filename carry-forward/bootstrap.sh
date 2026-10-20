#!/usr/bin/env bash
# Fresh Arch-based machine (Omarchy, CachyOS, plain Arch) -> Aditya's dev setup.
# Safe to re-run: every step skips what is already there.
set -euo pipefail

PACMAN=(
  base-devel git github-cli git-delta lazygit openssh
  fish zoxide eza bat fd fzf ripgrep ripgrep-all dust duf procs bottom btop
  hyperfine tokei xh yq aria2 wget rsync pv ncdu plocate man-db vim
  7zip unzip unrar ouch
  uv python jdk-openjdk android-tools
  ghostty zed tailscale qemu-desktop edk2-ovmf
  ttf-fira-code ttf-meslo-nerd noto-fonts noto-fonts-cjk noto-fonts-emoji
  libreoffice-fresh darktable vlc vlc-plugins-all qbittorrent loupe papers
)
AUR=(
  yay google-chrome slack-desktop vesktop otf-apple-sf-pro
  t3code-nightly-bin typeaside-bin wordcraft-bin
)
RUST_TARGETS=(aarch64-apple-darwin x86_64-pc-windows-msvc)
CARGO_CRATES=(cargo-bloat cargo-xwin)
BUN_GLOBALS=(convex wrangler)
NPM_GLOBALS=(pnpm agent-browser @opencode/cli @earendil-works/pi-coding-agent)
UV_TOOLS=(terminaltexteffects)
UV_PYTHONS=(3.12)
FISHER_PLUGINS=(ilancosman/tide@v6 patrickf1/fzf.fish jorgebucaran/autopair.fish meaningful-ooo/sponge)

step() { printf '\n\033[1m==> %s\033[0m\n' "$*"; }
has() { command -v "$1" >/dev/null 2>&1; }
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.bun/bin:$HOME/.vite-plus/bin:$HOME/.fly/bin:$PATH"

step "pacman packages"
sudo pacman -Syu --needed --noconfirm "${PACMAN[@]}"

step "AUR packages"
if ! has yay; then
  tmp=$(mktemp -d)
  git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
  (cd "$tmp/yay-bin" && makepkg -si --noconfirm)
fi
yay -S --needed --noconfirm "${AUR[@]}"

step "Rust"
has rustup || curl -fsSL https://sh.rustup.rs | sh -s -- -y --no-modify-path
rustup default stable
rustup component add clippy rustfmt
rustup target add "${RUST_TARGETS[@]}"
for c in "${CARGO_CRATES[@]}"; do cargo install --list | grep -q "^$c " || cargo install --locked "$c"; done

step "Bun"
has bun || curl -fsSL https://bun.sh/install | bash
bun add -g "${BUN_GLOBALS[@]}"

step "Node via Vite+"
has vp || curl -fsSL https://vite.plus | bash
npm config set prefix "$HOME/.local"
npm install -g "${NPM_GLOBALS[@]}"

step "Python via uv"
uv python install "${UV_PYTHONS[@]}"
for t in "${UV_TOOLS[@]}"; do uv tool install "$t"; done

step "Agent CLIs"
has claude || curl -fsSL https://claude.ai/install.sh | bash
has codex || curl -fsSL https://github.com/openai/codex/releases/latest/download/install.sh | sh

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

step "Done. Manual follow-ups"
cat <<'EOF'
  gh auth login            # git credentials go through gh
  tailscale up
  claude / codex / opencode / pi  # log in to each
  tar -xzf carry-forward-*.tar.gz -C ~ && systemctl --user daemon-reload
EOF
