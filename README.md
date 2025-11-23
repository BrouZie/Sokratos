# SokratOS

> A biased, opinionated Arch Linux + Hyprland setup focused on aesthetics, productivity, and customization

SokratOS is a comprehensive dotfiles and configuration management system for Arch Linux featuring the Hyprland compositor. It provides an elegant, functional desktop environment with dynamic theming, custom utilities, and a curated selection of tools for development and daily use.

## ✨ Features

- 🎨 **Dynamic Theming**: Automatic color scheme generation from wallpapers using `matugen` and `pywal`
- 🎯 **11 Pre-configured Supplimentary Themes**: Including Catppuccin, Gruvbox, TokyoNight, Nord, and more
- 🖥️ **Hyprland Compositor**: Modern Wayland compositor with beautiful animations and tiling
- 🛠️ **Custom Utility Scripts**: Theme switching, focus mode, screen recording, and more
- 🔧 **Development Ready**: Docker, development tools, and Neovim configuration included
- 📱 **Modern UI Components**: Waybar, Rofi, SwayNC for notifications and menus

## 📸 Preview

![preview1](docs/images/preview4.png)

![preview2](docs/images/preview3.png)

## 🚀 Installation

### Prerequisites

- Fresh or minimal Arch Linux installation
- Internet connection

### Quick Start

1. Clone the repository:
```bash
git clone https://github.com/BrouZie/Sokratos.git ~/.local/share/Sokratos
```

2. Run the installation script:
```bash
bash ~/.local/share/Sokratos/install.sh
```

The installer will:
- Set up auto-login configuration
- Install all required packages (from official repos and AUR)
- Configure Hyprland and all desktop components
- Set up terminal tools and development environment
- Install and configure themes
- Set up custom utility scripts

### Installation Components

The installation is organized into several modules:

- **Prerequisites**: AUR helper, network, graphics drivers (Intel/NVIDIA support)
- **Terminal**: CLI tools, development environment, Docker, firewall
- **Desktop**: Hyprland, Waybar, Rofi, audio/Bluetooth, fonts
- **Extras**: Power management, printer support, additional utilities

## 📦 Included Components

### Desktop Environment
- **Compositor**: Hyprland with custom configuration
- **Bar**: Waybar with custom modules
- **Launcher**: Rofi application launcher
- **Notifications**: SwayNC notification daemon
- **Lock Screen**: Hyprlock
- **Idle Manager**: Hypridle
- **Wallpaper**: swww wallpaper daemon

### Terminal & CLI Tools
- **Terminal**: Kitty with custom theming
- **Shell**: Bash with custom configuration
- **Multiplexer**: Tmux with TPM plugin manager
- **Editor**: Neovim (from external dotfiles)
- **File Manager**: eza (modern ls replacement)
- **System Monitor**: btop
- **Audio Visualizer**: cava
- **System Info**: fastfetch

### Development Tools
- Docker & Docker Compose
- Various language toolchains
- UV (Python package manager)
- Version control tools

### Theming System
- **matugen**: Material color generation from wallpapers
- **pywal**: Application theming
- **pywalfox**: Firefox theme integration
- 11 pre-configured color schemes for the terminal

## 🎨 Available Themes

SokratOS includes 11 carefully curated color schemes:

- Catppuccin
- Cyberpunk
- Everforest
- Gruvbox
- Kanagawa
- Nightfox
- Nord
- Nvim Dark
- Osaka Jade
- Rosé Pine
- TokyoNight

Switch themes using the `sokratos-themes` command or apply a theme from a wallpaper with `sokratos-apply-theme`.

## 🛠️ Custom Utilities

SokratOS provides several custom scripts in the `bin` directory:

- `sokratos-apply-theme <image>`: Apply theme from wallpaper image
- `sokratos-next-theme`: Interactive theme selector
- `sokratos-night-mode`: Toggle night mode
- `sokratos-focus-mode`: Minimize distractions
- `sokratos-floaterminal`: Launch floating terminal
- `sokratos-cheat-sheet`: Quick cheat.sh utilizing curl
- `sokratos-wf-recorder`: Screen recording helper
- `refresh-app-daemons`: Restart UI components

## ⚙️ Configuration

### User Configurations

After installation, you can customize your setup by editing these files:

- `~/.config/hypr/bindings.conf`: Custom keybindings
- `~/.config/hypr/envs.conf`: Environment variables
- `~/.config/hypr/monitors.conf`: Monitor configuration
- `~/.config/hypr/autostart.conf`: Autostart applications

### Theme Configuration

The current terminal theme is symlinked at:
- `~/.config/sokratos/current/theme/colors.conf`

## 📁 Project Structure

```
Sokratos/
├── bin/                    # Custom utility scripts
├── docs/                   # Documentation and screenshots
├── install/                # Installation scripts
│   ├── configs/           # Configuration files
│   ├── desktop/           # Desktop environment setup
│   ├── prerequisites/     # System prerequisites
│   ├── terminal/          # Terminal and CLI tools
│   └── xtras/             # Additional features
├── themes/                # Pre-configured color schemes
├── default/               # Default configurations
├── share/                 # Shared data
├── install.sh             # Main installation script
├── pacman.txt             # Official repo packages list
└── paru.txt               # AUR packages list
```

## 🔧 Post-Installation

### Setting Up Monitors

Edit `~/.config/hypr/monitors.conf` to configure your displays:

```conf
monitor=DP-1,1920x1080@144,0x0,1
```

### Adding Keybindings

Add custom keybindings to `~/.config/hypr/bindings.conf`:

```conf
bind = SUPER, T, exec, kitty
```

### Autostart Applications

Add applications to launch at startup in `~/.config/hypr/autostart.conf`:

```conf
exec-once = discord
```

## 🎯 Hardware Support

- **Intel Graphics**: Automatic Intel GPU configuration
- **NVIDIA Graphics**: Optional NVIDIA driver installation and configuration
- **Network**: NetworkManager with GUI support
- **Bluetooth**: Bluez with GUI controls
- **Audio**: Pipewire with full audio stack

## 🤝 Contributing

This is a personal setup, but feel free to fork and adapt it to your needs. Pull requests for bug fixes are welcome!

## 📝 License

This project is open source and available for personal use. Individual components may have their own licenses.

## 🙏 Credits

- Built for Arch Linux
- Uses the Hyprland compositor
- Neovim configuration from [BrouZie/dotfiles](https://github.com/BrouZie/dotfiles)
- Inspired by the Linux ricing community and Omarchy

## 📞 Support

For issues and questions, please open an issue on the GitHub repository.

---

**Note**: This is an opinionated setup. It's recommended to review the installation scripts and customize them to your preferences before running.
