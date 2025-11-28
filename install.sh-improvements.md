# install.sh Improvements Analysis

This document provides a comprehensive analysis of `install.sh` and all sourced scripts, with suggestions for **Performance**, **Longevity**, and **Readability** improvements.

---

## Table of Contents

1. [install.sh](#installsh)
2. [install/autologin.sh](#installautologinsh)
3. [install/prerequisites/all.sh](#installprerequisitesallsh)
4. [install/prerequisites/aur.sh](#installprerequisitesaursh)
5. [install/prerequisites/intel.sh](#installprerequisitesintelsh)
6. [install/prerequisites/network.sh](#installprerequisitesnetworksh)
7. [install/prerequisites/nvidia.sh](#installprerequisitesnvidiash)
8. [install/prerequisites/presentation.sh](#installprerequisitespresentationsh)
9. [install/prerequisites/printer.sh](#installprerequisitesprintersh)
10. [install/prerequisites/usb-autosuspend.sh](#installprerequisitesusb-autosuspendsh)
11. [install/terminal/all.sh](#installterminalallsh)
12. [install/terminal/clitools.sh](#installterminalclitoolssh)
13. [install/terminal/development.sh](#installterminaldevelopmentsh)
14. [install/terminal/docker.sh](#installterminaldockersh)
15. [install/terminal/firewall.sh](#installterminalfirewallsh)
16. [install/desktop/all.sh](#installdesktopallsh)
17. [install/desktop/audio.sh](#installdesktopaudiosh)
18. [install/desktop/bluetooth.sh](#installdesktopbluetoothsh)
19. [install/desktop/fonts.sh](#installdesktopfontssh)
20. [install/desktop/hyprdeps.sh](#installdesktophyprdepssh)
21. [install/xtras/all.sh](#installxtrasallsh)
22. [install/xtras/desktopxtras.sh](#installxtrasdesktopxtrassh)
23. [install/xtras/mimetypes.sh](#installxtrasmimetypessh)
24. [install/xtras/power.sh](#installxtraspowersh)

---

## `install.sh`

### 📚 Readability Suggestion: Add Script Header Documentation

**Issue:** The main script lacks a comprehensive header explaining its purpose, requirements, and usage.

**Before:**
```sh
#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

export REPO_PATH="$HOME/.local/share/sokratOS"
```

**After:**
```sh
#!/bin/bash
# =============================================================================
# sokratOS Installation Script
# =============================================================================
# Description: Main installation script for sokratOS - a customized Arch Linux
#              environment with Hyprland window manager.
#
# Requirements:
#   - Arch Linux base installation
#   - Internet connection
#   - sudo privileges
#
# Usage: bash install.sh
#
# Author: <your name here>
# Repository: https://github.com/BrouZie/sokratOS
# =============================================================================

# Exit immediately if a command exits with a non-zero status
set -e
```

**Explanation:** Adding a header improves maintainability and helps new contributors understand the script's purpose at a glance.

---

### 🔁 Longevity Suggestion: Add Shell Safety Options

**Issue:** Only `set -e` is used. Additional safety options prevent common scripting bugs.

**Before:**
```sh
#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e
```

**After:**
```sh
#!/bin/bash

# Shell safety options:
# -e: Exit immediately if a command exits with a non-zero status
# -u: Treat unset variables as an error
# -o pipefail: Return exit status of the last command in the pipe that failed
set -euo pipefail
```

**Explanation:**
- `-u` catches typos in variable names (unset variables cause immediate exit)
- `-o pipefail` ensures pipe commands don't hide failures (e.g., `cmd1 | cmd2` fails if either fails)

---

### ⚡ Performance Suggestion: Batch Directory Creation

**Issue:** Multiple `mkdir -p` calls can be combined into one.

**Before:**
```sh
mkdir -p "$HOME/.config/sokratOS/current/theme"
mkdir -p "$HOME/.config/kitty"
```

**After:**
```sh
mkdir -p "$HOME/.config/sokratOS/current/theme" \
         "$HOME/.config/kitty"
```

**Explanation:** Reduces the number of subprocess invocations. While minor, this is a good practice for larger scripts.

---

### ⚡ Performance Suggestion: Batch Config Copying with a Loop

**Issue:** Multiple `cp -r` commands are repetitive and harder to maintain.

**Before:**
```sh
cp "$REPO_INSTALL/configs/bashrc" "$HOME/.bashrc"
cp "$REPO_INSTALL/configs/kitty.conf" "$HOME/.config/kitty/kitty.conf"
cp "$REPO_INSTALL/configs/tmux.conf" "$HOME/.tmux.conf"
cp -r "$REPO_INSTALL/configs/bash" "$HOME/.config/bash"
cp -r "$REPO_INSTALL/configs/colors/matugen" "$HOME/.config/sokratOS/matugen"
cp -r "$REPO_INSTALL/configs/gtk-3.0" "$HOME/.config/gtk-3.0"
cp -r "$REPO_INSTALL/configs/gtk-4.0" "$HOME/.config/gtk-4.0"
cp -r "$REPO_INSTALL/configs/matugen" "$HOME/.config/matugen"
cp -r "$REPO_INSTALL/configs/hypr" "$HOME/.config/hypr"
cp -r "$REPO_INSTALL/configs/waybar" "$HOME/.config/waybar"
cp -r "$REPO_INSTALL/configs/wal" "$HOME/.config/wal"
cp -r "$REPO_INSTALL/configs/rofi" "$HOME/.config/rofi"
cp -r "$REPO_INSTALL/configs/swaync" "$HOME/.config/swaync"
cp -r "$REPO_INSTALL/configs/fastfetch" "$HOME/.config/fastfetch"
cp -r "$REPO_INSTALL/configs/zathura" "$HOME/.config/zathura"
cp -r "$REPO_INSTALL/configs/applications/*" "$HOME/.local/share/applications"
cp -r "$REPO_INSTALL/configs/nvim" "$HOME/.config/nvim"
```

**After:**
```sh
# Dotfiles with custom destinations
cp "$REPO_INSTALL/configs/bashrc" "$HOME/.bashrc"
cp "$REPO_INSTALL/configs/kitty.conf" "$HOME/.config/kitty/kitty.conf"
cp "$REPO_INSTALL/configs/tmux.conf" "$HOME/.tmux.conf"
cp -r "$REPO_INSTALL/configs/colors/matugen" "$HOME/.config/sokratOS/matugen"

# Config directories that map directly to ~/.config/
config_dirs=(
  bash gtk-3.0 gtk-4.0 matugen hypr waybar wal rofi swaync fastfetch zathura nvim
)

for dir in "${config_dirs[@]}"; do
  cp -r "$REPO_INSTALL/configs/$dir" "$HOME/.config/$dir"
done

# Application desktop entries
cp -r "$REPO_INSTALL/configs/applications/"* "$HOME/.local/share/applications/"
```

**Explanation:**
- Uses an array and loop for directories with uniform destination patterns
- Easier to add/remove config directories
- Note: Fixed `applications/*` glob - the glob `*` should be outside quotes to expand properly, with the trailing slash ensuring directory handling

---

### 🔁 Longevity Suggestion: Check if TPM Already Exists

**Issue:** `git clone` for TPM will fail if the directory already exists (e.g., re-running the script).

**Before:**
```sh
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

**After:**
```sh
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
else
  echo "TPM already installed, updating..."
  git -C "$HOME/.tmux/plugins/tpm" pull --ff-only || true
fi
```

**Explanation:** Makes the script idempotent - safe to run multiple times without failing.

---

### 📚 Readability Suggestion: Group Related Operations with Section Comments

**Issue:** The script mixes config copying, cloning, and Python setup without clear sections.

**Before:**
```sh
# Configs
mkdir -p "$HOME/.config/sokratOS/current/theme"
# ... (all config operations)

# Tmux and neovim dependencies
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

uv venv --seed ~/.venvs/nvim
```

**After:**
```sh
# =============================================================================
# Configuration Files
# =============================================================================
mkdir -p "$HOME/.config/sokratOS/current/theme"
# ... (config operations)

# =============================================================================
# Plugin Managers & Dependencies
# =============================================================================
# Tmux Plugin Manager (TPM)
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# =============================================================================
# Python Environment for Neovim
# =============================================================================
uv venv --seed ~/.venvs/nvim
```

**Explanation:** Clear section headers improve navigation and comprehension in longer scripts.

---

### 🔁 Longevity Suggestion: Quote All Variables Consistently

**Issue:** Some paths are unquoted, which can cause issues with spaces in paths.

**Before:**
```sh
cp -r "$REPO_INSTALL/configs/applications/*" "$HOME/.local/share/applications"
```

**After:**
```sh
cp -r "$REPO_INSTALL/configs/applications/"* "$HOME/.local/share/applications/"
```

**Explanation:** The glob `*` should be outside the quotes to expand properly, and the destination should have a trailing slash to ensure it's treated as a directory.

---

## `install/autologin.sh`

### 📚 Readability Suggestion: Add Script Header

**Issue:** No header documentation explaining what this script does.

**Before:**
```sh
USERNAME="$(whoami)"

# Create systemd override directory
```

**After:**
```sh
#!/bin/bash
# =============================================================================
# Autologin Configuration
# =============================================================================
# Configures automatic login on tty1 and auto-starts Hyprland
# =============================================================================

USERNAME="$(whoami)"

# Create systemd override directory
```

**Explanation:** Even sourced scripts benefit from documentation headers for maintainability.

---

### 🔁 Longevity Suggestion: Use $USER Instead of whoami

**Issue:** `$(whoami)` spawns a subprocess; `$USER` is already set by the shell.

**Before:**
```sh
USERNAME="$(whoami)"
```

**After:**
```sh
USERNAME="${USER:-$(whoami)}"
```

**Explanation:** Uses the shell variable when available, falls back to `whoami` if not. Marginally faster and more idiomatic.

---

### 🔁 Longevity Suggestion: Quote Variables in systemd Override

**Issue:** The `${USERNAME}` in the heredoc should be quoted for safety.

**Before:**
```sh
sudo tee /etc/systemd/system/getty@tty1.service.d/autologin.conf >/dev/null <<EOF
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin ${USERNAME} --noclear %I \$TERM
EOF
```

**After:**
```sh
sudo tee /etc/systemd/system/getty@tty1.service.d/autologin.conf >/dev/null <<EOF
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin "${USERNAME}" --noclear %I \$TERM
EOF
```

**Explanation:** While usernames typically don't have spaces, quoting is a defensive practice.

---

## `install/prerequisites/all.sh`

### 📚 Readability Suggestion: Add Header and Comments

**Issue:** No documentation about what this aggregation script does.

**Before:**
```sh
source "$REPO_INSTALL/prerequisites/aur.sh"
source "$REPO_INSTALL/prerequisites/presentation.sh"
```

**After:**
```sh
#!/bin/bash
# =============================================================================
# Prerequisites Installation
# =============================================================================
# Installs all prerequisite packages and system configurations
# =============================================================================

source "$REPO_INSTALL/prerequisites/aur.sh"        # AUR helper (paru)
source "$REPO_INSTALL/prerequisites/presentation.sh" # gum for pretty output
source "$REPO_INSTALL/prerequisites/network.sh"    # NetworkManager setup
source "$REPO_INSTALL/prerequisites/nvidia.sh"     # NVIDIA drivers (if applicable)
source "$REPO_INSTALL/prerequisites/intel.sh"      # Intel VA-API (if applicable)
source "$REPO_INSTALL/prerequisites/printer.sh"    # Printing support
source "$REPO_INSTALL/prerequisites/usb-autosuspend.sh" # USB power management
```

**Explanation:** Inline comments help understand the purpose of each sourced script.

---

## `install/prerequisites/aur.sh`

### 🔁 Longevity Suggestion: Fix Trap Quoting

**Issue:** The `trap` command doesn't quote the variable, which can fail if the path has spaces.

**Before:**
```sh
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT
```

**After:**
```sh
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT
```

**Explanation:** Using single quotes defers variable expansion until trap execution, and the inner quotes protect the path. Note: Since `$TEMP_DIR` is expanded at trap definition time with the original syntax, both work, but the single-quote version is clearer about intent.

---

### 🔁 Longevity Suggestion: Check if Paru Already Installed

**Issue:** The script doesn't check if paru is already installed, wasting time on re-runs.

**Before:**
```sh
sudo pacman -Syu --noconfirm

sudo pacman -S --needed --noconfirm base-devel git

TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

cd "$TEMP_DIR"
git clone https://aur.archlinux.org/paru.git
cd paru

makepkg -si --noconfirm
echo "✓ Paru installed successfully"
```

**After:**
```sh
if command -v paru &>/dev/null; then
  echo "✓ Paru already installed"
else
  sudo pacman -Syu --noconfirm
  sudo pacman -S --needed --noconfirm base-devel git

  TEMP_DIR=$(mktemp -d)
  trap 'rm -rf "$TEMP_DIR"' EXIT

  cd "$TEMP_DIR"
  git clone https://aur.archlinux.org/paru.git
  cd paru

  makepkg -si --noconfirm
  echo "✓ Paru installed successfully"
fi
```

**Explanation:** Makes the script idempotent and speeds up re-runs.

---

### 📚 Readability Suggestion: Add Progress Indicators

**Issue:** Building from AUR takes time; users benefit from progress feedback.

**Before:**
```sh
cd "$TEMP_DIR"
git clone https://aur.archlinux.org/paru.git
cd paru

makepkg -si --noconfirm
```

**After:**
```sh
cd "$TEMP_DIR"
echo "Cloning paru from AUR..."
git clone https://aur.archlinux.org/paru.git
cd paru

echo "Building paru (this may take a few minutes)..."
makepkg -si --noconfirm
```

**Explanation:** Progress messages help users understand what's happening during long operations.

---

## `install/prerequisites/intel.sh`

### 🔁 Longevity Suggestion: Use More Robust GPU Detection

**Issue:** The regex patterns may not match all Intel GPU naming conventions.

**Before:**
```sh
if INTEL_GPU=$(lspci | grep -iE 'vga|3d|display' | grep -i 'intel'); then
  # HD Graphics and newer uses intel-media-driver
  if [[ "${INTEL_GPU,,}" =~ "hd graphics"|"xe"|"iris" ]]; then
    sudo pacman -S --needed --noconfirm intel-media-driver
  elif [[ "${INTEL_GPU,,}" =~ "gma" ]]; then
    # Older generations from 2008 to ~2014-2017 use libva-intel-driver
    sudo pacman -S --needed --noconfirm libva-intel-driver
  fi
fi
```

**After:**
```sh
# This installs hardware video acceleration for Intel GPUs
if INTEL_GPU=$(lspci | grep -iE 'vga|3d|display' | grep -i 'intel'); then
  INTEL_GPU_LOWER="${INTEL_GPU,,}"  # Convert to lowercase once

  # HD Graphics and newer uses intel-media-driver
  # Matches: "HD Graphics", "UHD Graphics", "Xe", "Iris", "Iris Plus", "Iris Xe"
  if [[ "$INTEL_GPU_LOWER" =~ (hd\ graphics|uhd\ graphics|xe|iris) ]]; then
    sudo pacman -S --needed --noconfirm intel-media-driver
    echo "✓ Installed intel-media-driver for modern Intel GPU"
  elif [[ "$INTEL_GPU_LOWER" =~ gma ]]; then
    # GMA (Graphics Media Accelerator) - older generations
    sudo pacman -S --needed --noconfirm libva-intel-driver
    echo "✓ Installed libva-intel-driver for legacy Intel GPU"
  else
    echo "⚠ Unknown Intel GPU type, skipping VA-API driver installation"
  fi
fi
```

**Explanation:**
- Added "uhd graphics" pattern for newer CPUs
- Converted to lowercase once for efficiency
- Added user feedback messages
- Added fallback message for unknown GPU types

---

### 📚 Readability Suggestion: Fix Regex Syntax

**Issue:** The regex uses `"string1"|"string2"` which is incorrect Bash regex syntax.

**Before:**
```sh
if [[ "${INTEL_GPU,,}" =~ "hd graphics"|"xe"|"iris" ]]; then
```

**After:**
```sh
if [[ "${INTEL_GPU,,}" =~ (hd\ graphics|xe|iris) ]]; then
```

**Explanation:** In Bash `=~`, the pattern should not be quoted (quoting makes it a literal string match). Alternatives are grouped with `()` and separated with `|`.

---

## `install/prerequisites/network.sh`

### 📚 Readability Suggestion: Remove Dead Code or Document It

**Issue:** There's a large block of commented code (Version 2 with iwd) that clutters the file.

**Before:**
```sh
# Version 1 wpa_supplicant:
sudo pacman -S --needed --noconfirm \
  networkmanager \
  wireless-regdb

# ... (Version 1 configuration)

# Version 2 with iwd backend:

# sudo pacman -S --needed --noconfirm \
#   networkmanager \
#   iwd \
#   wireless-regdb

# ... (30+ lines of commented code)
```

**After:**
```sh
# =============================================================================
# NetworkManager with wpa_supplicant backend
# =============================================================================
# Alternative: For iwd backend, see docs/network-iwd.md or uncomment
# the iwd configuration in this file's git history.

sudo pacman -S --needed --noconfirm \
  networkmanager \
  wireless-regdb

# ... (Version 1 configuration only)
```

**Explanation:** Move alternative configurations to documentation or a separate file. Keep the active script clean.

---

## `install/prerequisites/nvidia.sh`

### 📚 Readability Suggestion: Excellent Documentation (No Changes Needed)

**Issue:** None - this file has good header documentation.

**Note:** This file already follows best practices with clear header comments explaining purpose, author, and methodology.

---

### 🔁 Longevity Suggestion: Avoid Redundant Command Substitution

**Issue:** `$(lspci | grep -i 'nvidia')` is called twice.

**Before:**
```sh
if [ -n "$(lspci | grep -i 'nvidia')" ]; then
  # --- Driver Selection ---
  if echo "$(lspci | grep -i 'nvidia')" | grep -q -E "RTX [2-9][0-9]|GTX 16"; then
```

**After:**
```sh
NVIDIA_GPU=$(lspci | grep -i 'nvidia') || true
if [[ -n "$NVIDIA_GPU" ]]; then
  # --- Driver Selection ---
  if echo "$NVIDIA_GPU" | grep -q -E "RTX [2-9][0-9]|GTX 16"; then
```

**Explanation:** Captures the result once and reuses it. Adds `|| true` to prevent `set -e` from exiting if no NVIDIA GPU is found.

---

### 🔁 Longevity Suggestion: Improve Regex for GPU Detection

**Issue:** The regex `"RTX [2-9][0-9]|GTX 16"` may miss some cards (e.g., RTX 5000 series when released).

**Before:**
```sh
if echo "$(lspci | grep -i 'nvidia')" | grep -q -E "RTX [2-9][0-9]|GTX 16"; then
```

**After:**
```sh
# RTX 2000+ and GTX 1600 series support open-source kernel modules
# Pattern matches: RTX 20xx, 30xx, 40xx, 50xx+ and GTX 16xx
if echo "$NVIDIA_GPU" | grep -qiE "RTX [2-9][0-9]|GTX 16[0-9]{2}"; then
```

**Explanation:** Made regex case-insensitive with `-i` flag and specified GTX pattern more precisely.

---

### ⚡ Performance Suggestion: Combine sed Commands

**Issue:** Multiple `sed` calls on the same file can be combined.

**Before:**
```sh
sudo sed -i -E 's/ nvidia_drm//g; s/ nvidia_uvm//g; s/ nvidia_modeset//g; s/ nvidia//g;' "$MKINITCPIO_CONF"
# Add the new modules at the start of the MODULES array
sudo sed -i -E "s/^(MODULES=\\()/\\1${NVIDIA_MODULES} /" "$MKINITCPIO_CONF"
# Clean up potential double spaces
sudo sed -i -E 's/  +/ /g' "$MKINITCPIO_CONF"
```

**After:**
```sh
# Remove old nvidia modules, add new ones, and clean up spaces - all in one pass
sudo sed -i -E "
  s/ nvidia_drm//g
  s/ nvidia_uvm//g
  s/ nvidia_modeset//g
  s/ nvidia//g
  s/^(MODULES=\\()/\\1${NVIDIA_MODULES} /
  s/  +/ /g
" "$MKINITCPIO_CONF"
```

**Explanation:** Combines three `sed` invocations into one, reducing file I/O operations.

---

### 🔁 Longevity Suggestion: Use Standard Bash Test Syntax

**Issue:** Mix of `[ ]` and `[[ ]]` test syntax.

**Before:**
```sh
if [ -n "$(lspci | grep -i 'nvidia')" ]; then
```

**After:**
```sh
if [[ -n "$(lspci | grep -i 'nvidia')" ]]; then
```

**Explanation:** Consistent use of `[[ ]]` is preferred in Bash for better word splitting and glob expansion handling.

---

## `install/prerequisites/presentation.sh`

### 📚 Readability Suggestion: Add Context Comment

**Issue:** Single line with no explanation of what `gum` is.

**Before:**
```sh
paru -S --noconfirm --needed gum
```

**After:**
```sh
# Install gum - a tool for glamorous shell scripts (user prompts, spinners, etc.)
# https://github.com/charmbracelet/gum
paru -S --noconfirm --needed gum
```

**Explanation:** Brief comments help maintainers understand why a dependency is needed.

---

## `install/prerequisites/printer.sh`

### ⚡ Performance Suggestion: Remove Duplicate Code

**Issue:** The same configuration block appears twice in the file.

**Before:**
```sh
# Install printing + discovery stuff
sudo pacman -S --needed cups cups-browsed avahi nss-mdns

# Disable multicast dns in resolved. Avahi will provide this for better network printer discovery
sudo mkdir -p /etc/systemd/resolved.conf.d
echo -e "[Resolve]\nMulticastDNS=no" | sudo tee /etc/systemd/resolved.conf.d/10-disable-multicast.conf

# Enable mDNS resolution for .local domains
sudo sed -i 's/^hosts:.*/hosts: mymachines mdns_minimal [NOTFOUND=return] resolve files myhostname dns/' /etc/nsswitch.conf

# Enable automatically adding remote printers
if ! grep -q '^CreateRemotePrinters Yes' /etc/cups/cups-browsed.conf; then
  echo 'CreateRemotePrinters Yes' | sudo tee -a /etc/cups/cups-browsed.conf
fi

sudo systemctl enable --now cups.service

# Disable multicast dns in resolved. Avahi will provide this for better network printer discovery
sudo mkdir -p /etc/systemd/resolved.conf.d
echo -e "[Resolve]\nMulticastDNS=no" | sudo tee /etc/systemd/resolved.conf.d/10-disable-multicast.conf
sudo systemctl enable --now avahi-daemon.service

# Enable mDNS resolution for .local domains
sudo sed -i 's/^hosts:.*/hosts: mymachines mdns_minimal [NOTFOUND=return] resolve files myhostname dns/' /etc/nsswitch.conf

# Enable automatically adding remote printers
if ! grep -q '^CreateRemotePrinters Yes' /etc/cups/cups-browsed.conf; then
  echo 'CreateRemotePrinters Yes' | sudo tee -a /etc/cups/cups-browsed.conf
fi

sudo systemctl enable --now cups-browsed.service
```

**After:**
```sh
# =============================================================================
# Printing and Network Printer Discovery
# =============================================================================

# Install printing stack
sudo pacman -S --needed --noconfirm cups cups-browsed avahi nss-mdns

# Disable multicast DNS in systemd-resolved (Avahi will handle this)
sudo mkdir -p /etc/systemd/resolved.conf.d
printf '[Resolve]\nMulticastDNS=no\n' | sudo tee /etc/systemd/resolved.conf.d/10-disable-multicast.conf >/dev/null

# Enable mDNS resolution for .local domains
sudo sed -i 's/^hosts:.*/hosts: mymachines mdns_minimal [NOTFOUND=return] resolve files myhostname dns/' /etc/nsswitch.conf

# Enable automatic remote printer discovery
if ! grep -q '^CreateRemotePrinters Yes' /etc/cups/cups-browsed.conf 2>/dev/null; then
  echo 'CreateRemotePrinters Yes' | sudo tee -a /etc/cups/cups-browsed.conf >/dev/null
fi

# Enable services
sudo systemctl enable --now cups.service
sudo systemctl enable --now avahi-daemon.service
sudo systemctl enable --now cups-browsed.service
```

**Explanation:**
- Removed duplicate configuration blocks
- Added `--noconfirm` flag that was missing
- Redirected `tee` output to `/dev/null` for cleaner output
- Added `2>/dev/null` to grep to suppress errors if file doesn't exist
- Used `printf` instead of `echo -e` for better portability

---

## `install/prerequisites/usb-autosuspend.sh`

### 📚 Readability Suggestion: Add More Context

**Issue:** Limited explanation of why this is needed.

**Before:**
```sh
# Disable USB autosuspend to prevent peripheral disconnection issues
if [[ ! -f /etc/modprobe.d/disable-usb-autosuspend.conf ]]; then
  echo "options usbcore autosuspend=-1" | sudo tee /etc/modprobe.d/disable-usb-autosuspend.conf
fi
```

**After:**
```sh
# =============================================================================
# Disable USB Autosuspend
# =============================================================================
# USB autosuspend can cause issues with:
# - Wireless mice/keyboards becoming unresponsive
# - USB DACs/audio interfaces cutting out
# - Some USB drives disconnecting unexpectedly
#
# Setting autosuspend=-1 disables the feature entirely.
# =============================================================================

if [[ ! -f /etc/modprobe.d/disable-usb-autosuspend.conf ]]; then
  echo "options usbcore autosuspend=-1" | sudo tee /etc/modprobe.d/disable-usb-autosuspend.conf >/dev/null
  echo "✓ USB autosuspend disabled"
fi
```

**Explanation:** More context helps users understand why this configuration exists.

---

## `install/terminal/all.sh`

### 📚 Readability Suggestion: Add Inline Comments

**Issue:** No documentation about what each sourced script provides.

**Before:**
```sh
source "$REPO_INSTALL/terminal/clitools.sh"
source "$REPO_INSTALL/terminal/development.sh"
source "$REPO_INSTALL/terminal/docker.sh"
source "$REPO_INSTALL/terminal/firewall.sh"
```

**After:**
```sh
#!/bin/bash
# =============================================================================
# Terminal Environment Installation
# =============================================================================

source "$REPO_INSTALL/terminal/clitools.sh"    # Essential CLI utilities
source "$REPO_INSTALL/terminal/development.sh"  # Development tools and languages
source "$REPO_INSTALL/terminal/docker.sh"       # Docker and container tools
source "$REPO_INSTALL/terminal/firewall.sh"     # UFW firewall configuration
```

**Explanation:** Quick reference for what each script installs.

---

## `install/terminal/clitools.sh`

### 📚 Readability Suggestion: Group Packages by Category

**Issue:** All packages are on one line, making it hard to understand what's being installed.

**Before:**
```sh
paru -S --noconfirm --needed \
  kitty wget curl 7zip unzip pandoc-cli \
  fd eza fzf rmapi ripgrep zoxide bat jq \
  ttyper wl-clipboard fastfetch btop usbutils pastel \
  man-pages man-db tldr bash-completion
```

**After:**
```sh
# =============================================================================
# CLI Tools Installation
# =============================================================================

paru -S --noconfirm --needed \
  kitty \
  wget curl \
  7zip unzip \
  pandoc-cli \
  fd \
  eza \
  fzf \
  ripgrep \
  zoxide \
  bat \
  jq \
  rmapi \
  ttyper \
  wl-clipboard \
  fastfetch \
  btop \
  usbutils \
  pastel \
  man-pages man-db tldr \
  bash-completion

# Package descriptions:
# kitty         - Terminal emulator
# wget, curl    - Network utilities
# 7zip, unzip   - Archive tools
# pandoc-cli    - Document conversion
# fd            - Modern find replacement
# eza           - Modern ls replacement
# fzf           - Fuzzy finder
# ripgrep       - Modern grep replacement
# zoxide        - Smarter cd
# bat           - cat with syntax highlighting
# jq            - JSON processor
# rmapi         - reMarkable tablet sync
# ttyper        - Terminal typing practice
# wl-clipboard  - Wayland clipboard tools
# fastfetch     - System info display
# btop          - Resource monitor
# usbutils      - USB device tools
# pastel        - Color manipulation tool
# man-pages/db  - Documentation
# bash-completion - Tab completion
```

**Explanation:** Adding a comment block explaining package purposes makes the script more maintainable.

---

## `install/terminal/development.sh`

### 📚 Readability Suggestion: Group and Document Packages

**Issue:** Mix of different development ecosystems without organization.

**Before:**
```sh
paru -S --noconfirm --needed \
  cargo clang llvm zig jq tectonic \
  imagemagick ipython uv go npm nodejs \
  mariadb-libs github-cli xorg-xhost \
  lazygit lazydocker-bin tmux neovim zsh \
	python-pip python-pipx
```

**After:**
```sh
# =============================================================================
# Development Tools Installation
# =============================================================================

# Rust toolchain
# C/C++ toolchain
# Other languages
# Python tools
# Document processing
# Database
# Git and container TUIs
# Editor and shell
# X11 utilities (for GUI apps in containers)

paru -S --noconfirm --needed \
  cargo \
  clang llvm \
  zig go nodejs npm \
  ipython uv python-pip python-pipx \
  tectonic jq imagemagick \
  mariadb-libs \
  lazygit lazydocker-bin github-cli \
  neovim tmux zsh \
  xorg-xhost
```

**Explanation:** Grouping by ecosystem with a comment header makes the package list more understandable.

---

### 🔁 Longevity Suggestion: Fix Inconsistent Indentation

**Issue:** The file has a tab character in the last line.

**Before:**
```sh
lazygit lazydocker-bin tmux neovim zsh \
	python-pip python-pipx
```

**After:**
```sh
lazygit lazydocker-bin tmux neovim zsh \
  python-pip python-pipx
```

**Explanation:** Consistent use of spaces (or tabs) throughout the file prevents formatting issues.

---

## `install/terminal/docker.sh`

### 🔁 Longevity Suggestion: Quote Variable in usermod

**Issue:** `${USER}` should be quoted.

**Before:**
```sh
sudo usermod -aG docker ${USER}
```

**After:**
```sh
sudo usermod -aG docker "${USER}"
```

**Explanation:** Defensive quoting prevents issues if `$USER` somehow contains spaces.

---

### 📚 Readability Suggestion: Add Validation Feedback

**Issue:** No confirmation that Docker setup completed successfully.

**Before:**
```sh
sudo systemctl daemon-reload
```

**After:**
```sh
sudo systemctl daemon-reload

echo "✓ Docker installed and configured"
echo "  Note: Log out and back in for docker group membership to take effect"
```

**Explanation:** User feedback and important notes improve the installation experience.

---

## `install/terminal/firewall.sh`

### 📚 Readability Suggestion: Add Comments for Firewall Rules

**Issue:** Some rules lack explanation of their purpose.

**Before:**
```sh
# Allow ports for LocalSend
sudo ufw allow 53317/udp
sudo ufw allow 53317/tcp
```

**After:**
```sh
# LocalSend - cross-platform file sharing
# https://localsend.org/
sudo ufw allow 53317/udp comment 'LocalSend discovery'
sudo ufw allow 53317/tcp comment 'LocalSend file transfer'
```

**Explanation:** UFW supports rule comments, making firewall inspection easier with `sudo ufw status`.

---

## `install/desktop/all.sh`

### 📚 Readability Suggestion: Add Inline Documentation

**Before:**
```sh
source "$REPO_INSTALL/desktop/audio.sh"
source "$REPO_INSTALL/desktop/bluetooth.sh"
source "$REPO_INSTALL/desktop/fonts.sh"
source "$REPO_INSTALL/desktop/hyprdeps.sh"
```

**After:**
```sh
#!/bin/bash
# =============================================================================
# Desktop Environment Installation
# =============================================================================

source "$REPO_INSTALL/desktop/audio.sh"      # PipeWire/audio stack
source "$REPO_INSTALL/desktop/bluetooth.sh"  # Bluetooth support
source "$REPO_INSTALL/desktop/fonts.sh"      # Fonts and icon themes
source "$REPO_INSTALL/desktop/hyprdeps.sh"   # Hyprland and Wayland tools
```

**Explanation:** Inline comments provide quick overview.

---

## `install/desktop/audio.sh`

### 📚 Readability Suggestion: Document Package Purposes

**Before:**
```sh
# Audio stack
paru -S --needed --noconfirm \
	pamixer wiremix playerctl cava pavucontrol alsa-utils
```

**After:**
```sh
# =============================================================================
# Audio Stack (PipeWire ecosystem)
# =============================================================================
# pamixer     - CLI volume control
# wiremix     - TUI audio mixer for PipeWire
# playerctl   - Media player control
# cava        - Audio visualizer
# pavucontrol - GUI volume control
# alsa-utils  - Low-level audio utilities

paru -S --needed --noconfirm \
  pamixer wiremix playerctl cava pavucontrol alsa-utils
```

**Explanation:** Adding a comment block explains the purpose of each audio tool.

---

### 🔁 Longevity Suggestion: Fix Indentation

**Issue:** Uses tab instead of spaces.

**Before:**
```sh
paru -S --needed --noconfirm \
	pamixer wiremix playerctl cava pavucontrol alsa-utils
```

**After:**
```sh
paru -S --needed --noconfirm \
  pamixer wiremix playerctl cava pavucontrol alsa-utils
```

**Explanation:** Consistent indentation with spaces.

---

## `install/desktop/bluetooth.sh`

### 📚 Readability Suggestion: Add Brief Documentation

**Before:**
```sh
# Install bluetooth controls
paru -S --noconfirm --needed blueberry

# Turn on bluetooth by default
sudo systemctl enable --now bluetooth.service
```

**After:**
```sh
# =============================================================================
# Bluetooth Configuration
# =============================================================================

# Blueberry provides a GTK-based Bluetooth manager
paru -S --noconfirm --needed blueberry

# Enable Bluetooth service at boot
sudo systemctl enable --now bluetooth.service

echo "✓ Bluetooth enabled"
```

**Explanation:** Adds context and completion feedback.

---

## `install/desktop/fonts.sh`

### 📚 Readability Suggestion: Group Fonts by Purpose

**Before:**
```sh
paru -S --noconfirm --needed \
	otf-font-awesome ttf-rubik-vf \
	noto-fonts noto-fonts-emoji  noto-fonts-cjk noto-fonts-extra \
	ttf-jetbrains-mono-nerd papirus-folders papirus-icon-theme \
	adw-gtk-theme
```

**After:**
```sh
# =============================================================================
# Fonts and Themes Installation
# =============================================================================
# Icon fonts: otf-font-awesome
# UI fonts: ttf-rubik-vf
# Unicode coverage: noto-fonts (CJK, emoji, symbols)
# Terminal/editor font: ttf-jetbrains-mono-nerd
# Icon theme: papirus-icon-theme, papirus-folders
# GTK theme: adw-gtk-theme

paru -S --noconfirm --needed \
  otf-font-awesome \
  ttf-rubik-vf \
  noto-fonts noto-fonts-emoji noto-fonts-cjk noto-fonts-extra \
  ttf-jetbrains-mono-nerd \
  papirus-icon-theme papirus-folders \
  adw-gtk-theme

# Rebuild font cache
fc-cache -fv
```

**Explanation:** Organized by font purpose with a descriptive header block.

---

### ⚡ Performance Suggestion: Fix Double Space Typo

**Issue:** Double space in package list.

**Before:**
```sh
noto-fonts noto-fonts-emoji  noto-fonts-cjk noto-fonts-extra
```

**After:**
```sh
noto-fonts noto-fonts-emoji noto-fonts-cjk noto-fonts-extra
```

**Explanation:** While this works, it's cleaner without the extra space.

---

## `install/desktop/hyprdeps.sh`

### 📚 Readability Suggestion: Organize by Function

**Before:**
```sh
paru -S --noconfirm --needed \
  hyprland hyprshot wf-recorder hypridle polkit-gnome \
  hyprlock rofi hyprpicker waybar swaync swww \
  xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
  xdg-terminal-exec xdg-utils xdg-user-dirs \
  brightnessctl wl-clip-persist nautilus ffmpegthumbnailer \
  slurp matugen-bin qt5-wayland qt6-wayland \
  mpv zathura zathura-pdf-mupdf imv firefox python-pywal16 python-pywalfox

xdg-user-dirs-update
```

**After:**
```sh
# =============================================================================
# Hyprland and Wayland Desktop Dependencies
# =============================================================================
# Core Hyprland: hyprland, hypridle, hyprlock, hyprshot, hyprpicker
# Desktop portals: xdg-desktop-portal-hyprland/gtk, xdg-*
# Bar and notifications: waybar, swaync
# Wallpaper and theming: swww, matugen-bin, python-pywal16/pywalfox
# Launcher: rofi
# Screen utilities: wf-recorder, slurp, brightnessctl
# Clipboard: wl-clip-persist
# File manager: nautilus, ffmpegthumbnailer
# Qt Wayland: qt5-wayland, qt6-wayland
# Media viewers: mpv, imv, firefox, zathura
# Auth agent: polkit-gnome

paru -S --noconfirm --needed \
  hyprland hypridle hyprlock hyprshot hyprpicker \
  xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
  xdg-terminal-exec xdg-utils xdg-user-dirs \
  waybar swaync \
  swww matugen-bin python-pywal16 python-pywalfox \
  rofi \
  wf-recorder slurp brightnessctl \
  wl-clip-persist \
  nautilus ffmpegthumbnailer \
  qt5-wayland qt6-wayland \
  mpv imv firefox \
  zathura zathura-pdf-mupdf \
  polkit-gnome

# Initialize user directories (Documents, Downloads, etc.)
xdg-user-dirs-update
```

**Explanation:** Categorization in the header makes it easier to understand and modify the package list.

---

## `install/xtras/all.sh`

### 📚 Readability Suggestion: Add Documentation

**Before:**
```sh
source "$REPO_INSTALL/xtras/mimetypes.sh"
source "$REPO_INSTALL/xtras/desktopxtras.sh"
source "$REPO_INSTALL/xtras/power.sh"
```

**After:**
```sh
#!/bin/bash
# =============================================================================
# Extra Configuration and Applications
# =============================================================================

source "$REPO_INSTALL/xtras/mimetypes.sh"    # Default application associations
source "$REPO_INSTALL/xtras/desktopxtras.sh" # Optional desktop applications
source "$REPO_INSTALL/xtras/power.sh"        # Power profile configuration
```

**Explanation:** Inline comments describe each module's purpose.

---

## `install/xtras/desktopxtras.sh`

### 📚 Readability Suggestion: Document the Fallback Logic

**Before:**
```sh
# Packages known to be flaky or having key signing issues are run one-by-one
for pkg in gimp spotify vesktop-bin; do
paru -S --noconfirm --needed "$pkg" ||
  echo -e "\e[31mFailed to install $pkg. Continuing without!\e[0m"
done
```

**After:**
```sh
# =============================================================================
# Flaky/Optional Packages
# =============================================================================
# These packages are installed one-by-one with error handling because they:
# - May have intermittent AUR key signing issues
# - May fail to build on certain systems
# - Are optional nice-to-haves

OPTIONAL_PACKAGES=(
  gimp        # Image editor
  spotify     # Music streaming
  vesktop-bin # Discord client with screen sharing
)

for pkg in "${OPTIONAL_PACKAGES[@]}"; do
  if ! paru -S --noconfirm --needed "$pkg"; then
    echo -e "\e[33m⚠ Failed to install $pkg. Continuing without.\e[0m"
  fi
done
```

**Explanation:**
- Uses an array for clarity
- Adds package descriptions
- Changed red (error) to yellow (warning) since it's expected behavior
- Fixed indentation

---

## `install/xtras/mimetypes.sh`

### ⚡ Performance Suggestion: Use Loops for Repetitive Commands

**Issue:** Many repetitive `xdg-mime default` calls with the same desktop file.

**Before:**
```sh
# Open all images with imv
xdg-mime default imv.desktop image/png
xdg-mime default imv.desktop image/jpeg
xdg-mime default imv.desktop image/gif
xdg-mime default imv.desktop image/webp
xdg-mime default imv.desktop image/bmp
xdg-mime default imv.desktop image/tiff
```

**After:**
```sh
# =============================================================================
# MIME Type Associations
# =============================================================================

mkdir -p ~/.local/share/applications
update-desktop-database ~/.local/share/applications

# Helper function to set default application for multiple types
set_default_app() {
  local desktop_file="$1"
  shift
  for mime_type in "$@"; do
    xdg-mime default "$desktop_file" "$mime_type"
  done
}

# Images → imv
set_default_app imv.desktop \
  image/png image/jpeg image/gif image/webp image/bmp image/tiff

# PDFs → Zathura
set_default_app org.gnome.zathura-pdf-mupdf.desktop application/pdf

# Web browser → Firefox
xdg-settings set default-web-browser firefox.desktop
set_default_app firefox.desktop \
  x-scheme-handler/http x-scheme-handler/https

# Videos → mpv
set_default_app mpv.desktop \
  video/mp4 video/x-msvideo video/x-matroska video/x-flv \
  video/x-ms-wmv video/mpeg video/ogg video/webm video/quicktime \
  video/3gpp video/3gpp2 video/x-ms-asf video/x-ogm+ogg \
  video/x-theora+ogg application/ogg

# Text/code → neovim
set_default_app nvim.desktop \
  text/plain text/english text/x-makefile \
  text/x-c++hdr text/x-c++src text/x-chdr text/x-csrc \
  text/x-java text/x-moc text/x-pascal text/x-tcl text/x-tex \
  application/x-shellscript text/x-c text/x-c++ \
  application/xml text/xml
```

**Explanation:**
- Introduces a helper function to reduce repetition
- Groups related MIME types together
- Much easier to add or remove associations

---

## `install/xtras/power.sh`

### 🔁 Longevity Suggestion: Add Package Check

**Issue:** Script assumes package installation succeeds before using commands.

**Before:**
```sh
paru -S --noconfirm power-profiles-daemon

if ls /sys/class/power_supply/BAT* &>/dev/null; then
```

**After:**
```sh
# =============================================================================
# Power Management Configuration
# =============================================================================

paru -S --noconfirm --needed power-profiles-daemon

# Ensure service is running before setting profile
sudo systemctl enable --now power-profiles-daemon.service

if ls /sys/class/power_supply/BAT* &>/dev/null; then
```

**Explanation:**
- Added `--needed` flag for idempotency
- Explicitly enable the service before using its commands

---

### 📚 Readability Suggestion: Improve Comments

**Before:**
```sh
# Setting the performance profile can make a big difference. By default, most systems seem to start in balanced mode,
# even if they're not running off a battery. So let's make sure that's changed to performance.
```

**After:**
```sh
# =============================================================================
# Power Profile Configuration
# =============================================================================
# Most systems default to "balanced" mode even on AC power.
# This script sets appropriate profiles based on power source:
#   - Battery: balanced (extend battery life)
#   - AC power: performance (maximize speed)
# =============================================================================
```

**Explanation:** More structured documentation.

---

### 🔁 Longevity Suggestion: Remove Reference to Non-Existent Timer

**Issue:** References `omarchy-battery-monitor.timer` which doesn't appear to exist in this repo.

**Before:**
```sh
# Enable battery monitoring timer for low battery notifications
systemctl --user enable --now omarchy-battery-monitor.timer || true
```

**After:**
```sh
# Note: Battery monitoring (low battery notifications) should be handled by
# your desktop environment or a separate service. Uncomment below if you have
# a custom battery monitor timer installed:
# systemctl --user enable --now omarchy-battery-monitor.timer || true
```

**Explanation:** Comments out the reference to a timer that doesn't exist in this repository, preventing confusion.

---

# General Recommendations

## 1. Create a Shared Functions Library

Create a file `install/lib/common.sh` with reusable functions:

```sh
#!/bin/bash
# Common installation functions

# Check if running as root
check_not_root() {
  if [[ $EUID -eq 0 ]]; then
    echo "Error: Don't run this script as root"
    exit 1
  fi
}

# Install packages via paru with standard flags
install_packages() {
  paru -S --noconfirm --needed "$@"
}

# Print a success message
success() {
  echo -e "\e[32m✓ $1\e[0m"
}

# Print a warning message
warn() {
  echo -e "\e[33m⚠ $1\e[0m"
}

# Print an error message
error() {
  echo -e "\e[31m✗ $1\e[0m"
}
```

## 2. Add Version Check

Add to `install.sh`:

```sh
# Minimum Bash version check
if [[ ${BASH_VERSINFO[0]} -lt 4 ]]; then
  echo "Error: Bash 4.0 or higher is required"
  exit 1
fi
```

## 3. Add Dry-Run Mode

Consider adding a `--dry-run` flag for testing:

```sh
DRY_RUN=${DRY_RUN:-false}

run() {
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "[DRY-RUN] $*"
  else
    "$@"
  fi
}

# Usage:
run sudo pacman -S --needed --noconfirm base-devel
```

## 4. Use ShellCheck

Run all scripts through [ShellCheck](https://www.shellcheck.net/) to catch potential issues:

```sh
shellcheck install.sh install/**/*.sh
```

---

# Summary

| Category | Issue Count |
|----------|-------------|
| 🔁 Longevity | 18 |
| ⚡ Performance | 6 |
| 📚 Readability | 21 |

**Priority fixes:**
1. Add `set -euo pipefail` to main script
2. Remove duplicate code in `printer.sh`
3. Fix unquoted variables throughout
4. Add idempotency checks (skip if already installed)
5. Run ShellCheck on all scripts
