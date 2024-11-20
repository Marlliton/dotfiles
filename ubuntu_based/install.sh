#!/bin/bash

RED=$'\e[0;31m'
GREEN=$'\e[0;32m'
YELLOW=$'\e[0;33m'
BLUE=$'\e[0;34m'
RESET=$'\e[0m'

# INSTALL DEFAULT APPS
install_default_apps="$PWD/default_apps.sh"
. "$install_default_apps"

