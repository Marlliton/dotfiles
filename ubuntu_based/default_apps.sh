#!/bin/bash

set -e  # Interrompe o script em caso de erro

# Cores para os logs
RED=$'\e[0;31m'
GREEN=$'\e[0;32m'
YELLOW=$'\e[0;33m'
BLUE=$'\e[0;34m'
MAGENTA=$'\e[0;35m'
CYAN=$'\e[0;36m'
RESET=$'\e[0m'

# Configuração de logs
LOG_FILE="install_$(date +%Y-%m-%d_%H-%M-%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

# Funções de log melhoradas
log() {
    local level="$1"
    local color="$2"
    local message="$3"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "${color}[${timestamp}] [${level}] ${message}${RESET}"
}

log_info() { log "INFO" "${BLUE}" "$1"; }
log_warn() { log "WARN" "${YELLOW}" "$1"; }
log_error() { log "ERROR" "${RED}" "$1"; }
log_success() { log "SUCCESS" "${GREEN}" "$1"; }
log_debug() { log "DEBUG" "${MAGENTA}" "$1"; }
log_step() { log "STEP" "${CYAN}" "$1"; }

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
  log_step "Atualizando sistema..."
  sudo apt update && sudo apt full-upgrade -y
  log_success "Sistema atualizado."
}

instalar_programas_apt() {
  log_step "Instalando programas via APT..."
  for programa in "${PROGRAMAS_APT[@]}"; do
    log_info "Verificando ${programa}" 
    if ! dpkg -s "$programa" >/dev/null 2>&1; then
      log_info "Instalando $programa via APT"
      sudo apt install -y "$programa"
      log_success "$programa instalado."
    else
      log_warn "$programa já está instalado."
    fi
  done
}

instalar_flatpak() {
  log_step "Instalando programas via Flatpak..."
  if ! command -v flatpak >/dev/null 2>&1; then
    log_info "Instalando Flatpak"
    sudo apt install -y flatpak
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    log_success "Flatpak instalado."
  else
    log_warn "Flatpak já está instalado."
  fi

  for programa in "${PROGRAMAS_FLATPAK[@]}"; do
    log_info "Verificando ${programa}" 
    if ! flatpak list | grep -q "$programa"; then
      log_info "Instalando $programa via Flatpak"
      flatpak install flathub "$programa" -y
      log_success "$programa instalado."
    else
      log_warn "$programa já está instalado via Flatpak."
    fi
  done
}

instalar_asdf() {
  log_step "Instalando ASDF..."
  if [ ! -d "$HOME/.asdf" ]; then
    log_info "Clonando repositório do ASDF..."
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.1
    . "$HOME/.asdf/asdf.sh"
    log_success "ASDF instalado."
  else
    log_warn "ASDF já está instalado."
  fi
}

carregar_asdf() {
  log_step "Carregando ASDF..."
  if [ -f "$HOME/.asdf/asdf.sh" ]; then
    . "$HOME/.asdf/asdf.sh"
  fi

  if [ -f "$HOME/.asdf/completions/asdf.bash" ]; then
    . "$HOME/.asdf/completions/asdf.bash"
  fi
}

adicionar_asdf_plugins() {
  log_step "Adicionando plugins ao ASDF..."
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
    log_info "Verificando plugin ${plugin_name}" 
    if ! asdf plugin list | grep -q "^$plugin_name$"; then
      log_info "Adicionando plugin ${plugin_name}"
      asdf plugin add $plugin
      log_success "Plugin ${plugin_name} adicionado."
    else
      log_warn "Plugin ${plugin_name} já está instalado."
    fi
  done
}

instalar_asdf_apps() {
  log_step "Instalando versões com ASDF"

  # Para o Rust.js
  log_info "Instalando Rust"
  asdf install rust latest
  asdf global rust latest
  if ! command -v cargo >/dev/null 2>&1; then
    log_warn "Adicionando temporariamente o Cargo ao PATH"
    export PATH="$HOME/.cargo/bin:$PATH"
  fi
  log_success "Rust instalado"

  # Para o Node.js
  log_info "Instalando Node.js"
  asdf install nodejs latest
  asdf global nodejs latest
  log_success "Node.js instalado"

  # Para o Neovim
  log_info "Instalando Neovim"
  asdf install neovim stable
  asdf global neovim stable
  log_success "Neovim instalado"

  # Para o Golang
  log_info "Instalando Golang"
  asdf install golang latest
  asdf global golang latest
  log_success "Golang instalado"

  # Para o Python
  log_info "Instalando Python"
  log_info "Instalando dependências para Python"
  sudo apt update && sudo apt install -y build-essential libssl-dev zlib1g-dev \
      libbz2-dev libreadline-dev libsqlite3-dev curl git \
      libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

  asdf install python latest
  asdf global python latest
  log_success "Python instalado"
}


install_docker() {
  log_step "Instalando Docker..."
  sudo apt-get remove -y docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc || true
  log_info "Atualizando repositórios..."
  sudo apt-get update
  log_info "Instalando pacotes Docker..."
  sudo apt-get install -y ca-certificates curl
  log_info "Adicionando chave Docker..."
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  log_info "Atualizando repositórios do Docker..."
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  log_success "Docker instalado."

  log_info "Adicionando usuário ao grupo docker..."
  sudo groupadd docker || true
  sudo usermod -aG docker "$USER"
}

main() {
  log_step "Iniciando instalação..."

  atualizar_sistema
  instalar_programas_apt
  instalar_flatpak
  instalar_asdf
  carregar_asdf
  adicionar_asdf_plugins
  instalar_asdf_apps 
  install_docker

  log_success "Instalação concluída."
}

main
