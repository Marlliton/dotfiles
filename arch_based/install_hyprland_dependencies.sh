#!/bin/bash

RED=$'\e[0;31m'
GREEN=$'\e[0;32m'
YELLOW=$'\e[0;33m'
BLUE=$'\e[0;34m'
RESET=$'\e[0m'

PROGRAMAS_YAY=(
  "hyprshot"
  "swaync"
  "hyprlock"
  "hypridle"
  "hyprpaper"
  "nwg-look"
  "catppuccin-gtk-theme-mocha"
)


DEPS_HYPR=(
  "hyprland"
  "waybar"
  "wofi"
  "dolphin"
  "pavucontrol"
  "xdg-desktop-portal"
  "xdg-desktop-portal-hyprland"
  "archlinux-xdg-menu"
)

baixar_e_instalar_programas_pacman() {
  echo "${GREEN}[INICIANDO INSTALAÇÃO DOS PROGRAMAS PACMAN]${RESET}"
  for programa in "${DEPS_HYPR[@]}";
  do
    if ! pacman -Qi "$programa" >/dev/null 2>&1; then
      echo "${BLUE}[INSTALANDO] $programa via [PACMAN]${RESET}"
      sudo pacman -S "$programa" --noconfirm
    else 
      echo "${BLUE}[PROGRAMA < $programa > JÁ EXISTE]${RESET}"
    fi
  done
}

baixar_e_instalar_programas_yay() {
  echo "${GREEN}[INICIANDO INSTALAÇÃO DOS PROGRAMAS YAY]${RESET}"
  for programa in "${PROGRAMAS_YAY[@]}";
  do
    if ! yay -Q "$programa" >/dev/null 2>&1; then
      echo "${YELLOW}[INSTALANDO] $programa via [YAY]${RESET}"
      yay -S "$programa" --noconfirm
    else
      echo "${YELLOW}[PROGRAMA < $programa > JÁ EXISTE]${RESET}"
    fi
  done
}

definir_links_limbolico() {
  ( 
    CONFIG_DIRS=(
      "hyprpaper"
      "waybar"
      "wofi"
      "hyprlock"
      "hyprmocha"
    )
    DOTFILES_DIR="$HOME/dotfiles"

    cd "$DOTFILES_DIR" || exit 1

    for dir in "${CONFIG_DIRS[@]}"; do
      echo "${BLUE}[SOTW] processando o diretório: $dir ${RESET}"
      stow -v "$dir" -t "$HOME"
    done

    echo "[INFO] Processo de cofniguração de links simbólicos finalizado" 
  )
}


baixar_e_instalar_programas_pacman
baixar_e_instalar_programas_yay
definir_links_limbolico
