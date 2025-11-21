#!/bin/bash

sudo pacman -Syu --noconfirm

sudo pacman -S --needed --noconfirm base-devel git

TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

cd "$TEMP_DIR"
git clone https://aur.archlinux.org/paru.git
cd paru

makepkg -si --noconfirm
echo "✓ Paru installed successfully"
