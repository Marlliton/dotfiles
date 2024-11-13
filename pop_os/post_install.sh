#!/bin/bash

# Diretório de destino para os downloads
DEST_DIR="$HOME/Downloads"

# Define as sequências de escape ANSI para as cores
RED=$'\e[0;31m'
GREEN=$'\e[0;32m'
YELLOW=$'\e[0;33m'
BLUE=$'\e[0;34m'
RESET=$'\e[0m'

# Programas flatpak
PROGRAMAS_FLATPAK=(
  "com.discordapp.Discord"
  # "rest.insomnia.Insomnia"
  "io.beekeeperstudio.Studio"
  "org.flameshot.Flameshot"
  "io.github.shiftey.Desktop"
  "org.kde.kdenlive"
  "com.stremio.Stremio"
  "com.spotify.Client"
  "com.obsproject.Studio"
  "it.mijorus.smile"
)

PROGRAMAS_APT=(
  "git"
  "curl"
  "timeshift"
  "curl"
  "unzip"
  "gparted"
  "keepassxc"
  "gnome-boxes"
  "stow"
)

atualizar_sistema() {
  sudo apt update && sudo apt full-upgrade -y
}

atualizar_sistema

baixar_e_instalar_programas_flatpak() {
  if ! command -v flatpak >/dev/null 2>&1; then
   sudo apt install flatpak
  fi

  for programa in "${PROGRAMAS_FLATPAK[@]}"
  do
    if ! flatpak list | grep -q "$programa"; then
      # Instalando programa
      echo "[INSTALANDO] $programa:"
      flatpak install flathub "$programa" -y
    else
      echo "[PROGRAMA < $programa > JÁ EXISTE]"
    fi
  done
}

# install flatpak apps
baixar_e_instalar_programas_flatpak

baixar_e_instalar_programas_apt() {
  for programa in "${PROGRAMAS_APT[@]}";
  do
    if ! dpkg -s "$programa" >/dev/null 2>&1; then
      echo "[INSTALANDO] $programa via [APT]"
      sudo apt install "$programa" -y
    else 
      echo "[PROGRAMA < $programa > JÁ EXISTE]"
    fi
  done

  if ! command -v ulauncher >/dev/null 2>&1; then
    echo "${YELLOW}INSTALANDO U_LAUNCHER${RESET}"
    caminho_u_launcher_instalacao="$PWD/u_launcher/index.sh"
    . "$caminho_u_launcher_instalacao"
  fi
  
}

baixar_e_instalar_programas_apt
