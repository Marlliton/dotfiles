#!/bin/bash

set -e  # Interrompe o script em caso de erro

RED=$'\e[0;31m'
GREEN=$'\e[0;32m'
YELLOW=$'\e[0;33m'
BLUE=$'\e[0;34m'
RESET=$'\e[0m'

LOG_FILE="install.log"

log_info() { echo -e "${BLUE}[INFO] $1${RESET}" | tee -a "$LOG_FILE"; }
log_warn() { echo -e "${YELLOW}[WARN] $1${RESET}" | tee -a "$LOG_FILE"; }
log_error() { echo -e "${RED}[ERROR] $1${RESET}" | tee -a "$LOG_FILE"; }
log_success() { echo -e "${GREEN}[SUCCESS] $1${RESET}" | tee -a "$LOG_FILE"; }

PROGRAMAS_FLATPAK=(
  "com.discordapp.Discord"
  "io.beekeeperstudio.Studio"
  "org.flameshot.Flameshot"
  "com.obsproject.Studio"
)

PROGRAMAS_APT=(
  "git" "curl" "unzip" "gparted" "keepassxc" "stow" "zsh" "ripgrep" "gimp" "handbrake" "audacious" "alacarte" "xclip" "tmux" "vlc"
)

atualizar_sistema() {
  log_info "Atualizando sistema..."
  sudo apt update && sudo apt full-upgrade -y
}

instalar_programas_apt() {
  log_info "Instalando programas via APT..."
  for programa in "${PROGRAMAS_APT[@]}"; do
    if ! dpkg -s "$programa" >/dev/null 2>&1; then
      log_info "Instalando $programa via APT"
      sudo apt install -y "$programa"
    else
      log_warn "$programa já está instalado."
    fi
  done
}

instalar_flatpak() {
  log_info "Instalando programas via Flatpak..."
  if ! command -v flatpak >/dev/null 2>&1; then
    sudo apt install -y flatpak
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  fi

  for programa in "${PROGRAMAS_FLATPAK[@]}"; do
    if ! flatpak list | grep -q "$programa"; then
      log_info "Instalando $programa via Flatpak"
      flatpak install flathub "$programa" -y
    else
      log_warn "$programa já está instalado via Flatpak."
    fi
  done
}

instalar_asdf() {
  log_info "Instalando ASDF..."
  if [ ! -d "$HOME/.asdf" ]; then
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.1
    . "$HOME/.asdf/asdf.sh"
  else
    log_warn "ASDF já está instalado."
  fi
}

adicionar_asdf_plugins() {
  log_info "Adicionando plugins ao ASDF..."
  plugins=(
    "nodejs https://github.com/asdf-vm/asdf-nodejs.git"
    "neovim"
    "golang https://github.com/asdf-community/asdf-golang.git"
    "python"
    "dart https://github.com/patoconnor43/asdf-dart.git"
    "rust https://github.com/asdf-community/asdf-rust.git"
  )

  for plugin in "${plugins[@]}"; do
    plugin_name=$(echo "$plugin" | awk '{print $1}')
    if ! asdf plugin list | grep -q "^$plugin_name\$"; then
      log_info "Adicionando plugin $plugin_name"
      asdf plugin add $plugin
    else
      log_warn "Plugin $plugin_name já está instalado."
    fi
  done
}

install_docker() {
  log_info "Instalando Docker..."
  sudo apt-get remove -y docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc || true
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  sudo groupadd docker || true
  sudo usermod -aG docker "$USER"
  log_success "Docker instalado com sucesso."
}

main() {
  atualizar_sistema
  instalar_programas_apt
  instalar_flatpak
  instalar_asdf
  adicionar_asdf_plugins
  install_docker
  log_success "Instalação concluída com sucesso."
}

main
