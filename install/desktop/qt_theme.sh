#!/bin/bash

# Use dark mode for QT apps too (like kdenlive)
if ! yay -Q kvantum-qt5 &>/dev/null; then
  yay -S --noconfirm kvantum-qt5
fi

# Prefer dark mode everything
if ! yay -Q gnome-themes-extra &>/dev/null; then
  yay -S --noconfirm gnome-themes-extra # Adds Adwaita-dark theme
fi

gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
