# Creating user specific directories

mkdir -p "$HOME"/{Documents,Downloads,Music,Pictures,Videos}
mkdir -p "$HOME"/{Projects,School,Robotics}
mkdir -p "$HOME/.config"

cat > "$HOME/.config/user-dirs.dirs" << 'EOF'
XDG_DESKTOP_DIR="$HOME"
XDG_DOWNLOAD_DIR="$HOME/Downloads"
XDG_DOCUMENTS_DIR="$HOME/Documents"
XDG_PICTURES_DIR="$HOME/Pictures"
XDG_MUSIC_DIR="$HOME/Music"
XDG_VIDEOS_DIR="$HOME/Videos"
XDG_TEMPLATES_DIR="$HOME"
XDG_PUBLICSHARE_DIR="$HOME"
EOF

xdg-user-dirs-update

rmdir "$HOME/Desktop" "$HOME/Public" "$HOME/Templates" 2>/dev/null || true

# Update gnome settings
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

# Dark icon-folder theme
papirus-folders -C black --theme Papirus-Dark --update-caches

# Custom folder-icons for non-xdg-dirs
gio set "$HOME/Robotics" metadata::custom-icon-name "folder-development"
gio set "$HOME/Projects" metadata::custom-icon-name "folder-projects"
gio set "$HOME/School" metadata::custom-icon-name "folder-notes"
