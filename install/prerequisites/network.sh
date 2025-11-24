# Version 1 wpa_supplicant:
sudo pacman -S --needed --noconfirm \
  networkmanager \
  wireless-regdb

sudo systemctl enable --now NetworkManager.service

# Safety: make sure nothing is fighting NM
sudo systemctl disable --now systemd-networkd.service
sudo systemctl disable systemd-networkd-wait-online.service
sudo systemctl mask systemd-networkd-wait-online.service

# Version 2 with iwd backend:

# sudo pacman -S --needed --noconfirm \
#   networkmanager \
#   iwd \
#   wireless-regdb


# sudo mkdir -p /etc/NetworkManager/conf.d
# sudo tee /etc/NetworkManager/conf.d/wifi_backend.conf >/dev/null <<EOF
# [device]
# wifi.backend=iwd
# EOF

# sudo systemctl enable --now iwd.service
# sudo systemctl enable --now NetworkManager.service

# sudo systemctl disable --now wpa_supplicant.service
# sudo systemctl disable --now systemd-networkd.service
# sudo systemctl disable systemd-networkd-wait-online.service
# sudo systemctl mask systemd-networkd-wait-online.service
