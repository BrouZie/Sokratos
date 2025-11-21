USERNAME="$(whoami)"

# Create systemd override directory
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d

# Create the override to autologin your user on tty1
sudo tee /etc/systemd/system/getty@tty1.service.d/autologin.conf >/dev/null <<EOF
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin ${USERNAME} --noclear %I \$TERM
EOF

# Reload systemd and ensure getty@tty1 is enabled
sudo systemctl daemon-reload
sudo systemctl enable getty@tty1.service

# Add autostart behaviour with .bash_profile
PROFILE="$HOME/.bash_profile"

[ -f "$PROFILE" ] || touch "$PROFILE"

if ! grep -q 'exec Hyprland' "$PROFILE"; then
  {
    echo ''
    echo '# Auto-start Hyprland on login to tty1'
    echo '[[ -f ~/.bashrc ]] && . ~/.bashrc'
    echo '[[ $(tty) == /dev/tty1 ]] && exec Hyprland'
  } >> "$PROFILE"
fi
