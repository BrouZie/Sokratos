paru -S --noconfirm --needed \
	otf-font-awesome ttf-rubik-vf \
	noto-fonts noto-fonts-emoji  noto-fonts-cjk noto-fonts-extra \
	ttf-jetbrains-mono-nerd papirus-folders papirus-icon-theme \
	adw-gtk-theme

# Refresh fontconfig
fc-cache -fv
