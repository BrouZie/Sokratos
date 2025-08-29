#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

SOKRATOS_INSTALL=~/.config/sokratos/install/

# Give people a chance to retry running the installation
catch_errors() {
  echo -e "\n\e[31mSokratos installation failed!\e[0m"
  echo "You can retry by running: bash ~/.config/sokratos/install.sh"
}

trap catch_errors ERR

# Install yay, gum and pythonshit
source $SOKRATOS_INSTALL/prerequisites/aur.sh
source $SOKRATOS_INSTALL/prerequisites/presentation.sh

# Important terminaltools
source $SOKRATOS_INSTALL/terminal/network.sh
source $SOKRATOS_INSTALL/terminal/clitools.sh
source $SOKRATOS_INSTALL/terminal/development.sh
source $SOKRATOS_INSTALL/terminal/docker.sh
source $SOKRATOS_INSTALL/terminal/firewall.sh
source $SOKRATOS_INSTALL/terminal/nvim.sh

# Important desktop shit
source $SOKRATOS_INSTALL/desktop/fonts.sh
source $SOKRATOS_INSTALL/desktop/bluetooth.sh
source $SOKRATOS_INSTALL/desktop/hyprdeps.sh
source $SOKRATOS_INSTALL/desktop/printer.sh
source $SOKRATOS_INSTALL/desktop/qt_theme.sh

# Important xtras
source $SOKRATOS_INSTALL/xtras/mimetypes.sh
source $SOKRATOS_INSTALL/xtras/power.sh
source $SOKRATOS_INSTALL/xtras/desktopxtras.sh

echo "Done with installations!!"
