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
