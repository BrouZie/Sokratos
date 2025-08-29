yay -S --noconfirm --needed \
gnome-calculator gnome-keyring signal-desktop \
obsidian-bin libreoffice \
xournalpp localsend-bin

# Packages known to be flaky or having key signing issues are run one-by-one
for pkg in gimp typora spotify discord; do
yay -S --noconfirm --needed "$pkg" ||
  echo -e "\e[31mFailed to install $pkg. Continuing without!\e[0m"
done
