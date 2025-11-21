#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

SOKRATOS_PATH="$HOME/.local/share/sokratos"
SOKRATOS_INSTALL="$SOKRATOS_PATH/install"

# Give people a chance to retry running the installation
catch_errors() {
  echo -e "\n\e[31mSokratos installation failed!\e[0m"
  echo "You can retry by running: bash $SOKRATOS_INSTALL/install.sh"
}

trap catch_errors ERR

# Auto-login
source "$SOKRATOS_INSTALL/autologin.sh"

# Installation of key packages/programs
source "$SOKRATOS_INSTALL/prerequisites/all.sh"
source "$SOKRATOS_INSTALL/terminal/all.sh"
source "$SOKRATOS_INSTALL/desktop/all.sh"
source "$SOKRATOS_INSTALL/xtras/all.sh"

# Configs
mkdir -p "$HOME/.config/sokratos/current/theme"

cp "$SOKRATOS_INSTALL/configs/bashrc ~/.bashrc"
cp "$SOKRATOS_INSTALL/configs/kitty.conf $HOME/.config/kitty/kitty.conf"
cp -r "$SOKRATOS_INSTALL/configs/gtk-3.0 $HOME/.config/gtk-3.0"
cp -r "$SOKRATOS_INSTALL/configs/gtk-4.0 $HOME/.config/gtk-4.0"
cp -r "$SOKRATOS_INSTALL/configs/matugen $HOME/.config/matugen"
cp -r "$SOKRATOS_INSTALL/configs/wal $HOME/.config/wal"
cp -r "$SOKRATOS_INSTALL/configs/hypr $HOME/.config/hypr"
cp -r "$SOKRATOS_INSTALL/configs/waybar $HOME/.config/waybar"
cp -r "$SOKRATOS_INSTALL/configs/rofi $HOME/.config/rofi"
cp -r "$SOKRATOS_INSTALL/configs/swaync $HOME/.config/swaync"
cp -r "$SOKRATOS_INSTALL/configs/fastfetch $HOME/.config/fastfetch"

# Tmux and neovim
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
cp "$SOKRATOS_INSTALL/configs/tmux.conf ~/.tmux.conf"

uv venv --seed ~/.venvs/nvim
uv pip install -p ~/.venvs/nvim/bin/python \
    pynvim jupyter_client nbformat cairosvg pillow plotly kaleido \
    pyperclip requests websocket-client pnglatex

git clone https://github.com/BrouZie/dotfiles.git ~/dotfiles
cd "$HOME/dotfiles"
stow nvim

# Ensure wallpaper for first boot
mkdir -p "$HOME/Pictures/wallpaper"
cp "$SOKRATOS_INSTALL/configs/elden_purple.jpg"
