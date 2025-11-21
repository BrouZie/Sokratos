#!/bin/bash

paru -S --noconfirm --needed \
	libreoffice file-roller localsend-bin

# Packages known to be flaky or having key signing issues are run one-by-one
for pkg in gimp spotify vesktop-bin; do
paru -S --noconfirm --needed "$pkg" ||
  echo -e "\e[31mFailed to install $pkg. Continuing without!\e[0m"
done
