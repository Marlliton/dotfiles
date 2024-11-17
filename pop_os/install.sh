#!/bin/bash

# Diretório de destino para os downloads
DEST_DIR="$HOME/Downloads"

# Define as sequências de escape ANSI para as cores
RED=$'\e[0;31m'
GREEN=$'\e[0;32m'
YELLOW=$'\e[0;33m'
BLUE=$'\e[0;34m'
RESET=$'\e[0m'

# INSTALL DEFAULT APPS
install_apps="$PWD/pop_os/apps.sh"
. "$install_apps"

