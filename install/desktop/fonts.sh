#!/bin/bash

paru -S --noconfirm --needed \
	otf-font-awesome ttf-rubik ttf-cascadia-mono-nerd \
	noto-fonts noto-fonts-emoji  noto-fonts-cjk noto-fonts-extra \
	ttf-jetbrains-mono-nerd

# Refresh fontconfig
fc-cache -fv
