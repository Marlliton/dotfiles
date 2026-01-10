#!/bin/bash

# Obtém o diretório onde o próprio script está localizado para referenciar outros scripts de forma segura
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "$SCRIPT_DIR/logging.sh"

set -e

# Programas que existem nos repositórios oficiais
PROGRAMAS_PACMAN=(
  "git" "base-devel" "curl" "unzip" "gparted" "keepassxc" "stow"
  "fzf" "ripgrep" "gimp" "handbrake" "audacious" "xclip" "tmux" "vlc"
  "docker" "docker-compose" "fish" "kitty" "lazygit" "eza" "bat" "starship"
  "zoxide" "polkit-gnome" "archlinux-xdg-menu" "xdg-desktop-portal-hyprland" "xdg-desktop-portal-gtk"
  "dunst" "hyprpaper" "grim" "slurp" "swappy" "otf-font-awesome" "adwaita-icon-theme"
  "vlc" "kdenlive" "gwenview" "btop" "openssh" "rofi" "noto-fonts-emoji" "ttf-firacode-nerd" "ttf-cascadia-code-nerd"
  "waybar" "jq" "pavucontrol" "openssl" "zlib" "xz" "tk" "zstd"
)

# Programas que vamos buscar no AUR
PROGRAMAS_AUR=(
  "asdf-vm" "qt6ct-kde"
)

setup_yay() {
  if ! command -v yay >/dev/null 2>&1; then
    log_step "Instalando yay (AUR Helper)..."
    sudo pacman -S --needed --noconfirm base-devel git
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd -
    log_success "Yay instalado."
  else
    log_warn "Yay já está instalado."
  fi
}

atualizar_sistema() {
  log_step "Atualizando sistema completo (Pacman + AUR)..."
  yay -Syu --noconfirm
}

instalar_programas() {
  log_step "Instalando pacotes do repositório oficial..."
  sudo pacman -S --needed --noconfirm "${PROGRAMAS_PACMAN[@]}"

  log_step "Instalando pacotes do AUR..."
  yay -S --needed --noconfirm "${PROGRAMAS_AUR[@]}"
}

configurar_asdf() {
  log_step "Configurando ASDF..."
  # No Arch (via AUR), o asdf fica em /opt/asdf-vm/ ou é carregado via script
  # Adicionamos o source necessário para a sessão atual do script
  if [ -f /opt/asdf-vm/asdf.sh ]; then
    . /opt/asdf-vm/asdf.sh
  elif [ -f "$HOME/.asdf/asdf.sh" ]; then
    . "$HOME/.asdf/asdf.sh"
  fi
}

instalar_asdf_plugins() {
  log_step "Instalando linguagens via ASDF..."

  # Dependências para compilar linguagens no Arch

  local plugins=("nodejs" "neovim" "golang" "python" "rust")

  for plugin in "${plugins[@]}"; do
    asdf plugin add "$plugin" || true
    log_info "Instalando $plugin..."
    asdf install "$plugin" latest
    asdf set -u "$plugin" latest
  done
}

install_docker() {
  log_step "Configurando Docker..."

  # Determina o usuário alvo de forma robusta. Prioriza $SUDO_USER, depois $USER, e finalmente usa whoami.
  local target_user
  if [ -n "$SUDO_USER" ]; then
    target_user="$SUDO_USER"
  elif [ -n "$USER" ]; then
    target_user="$USER"
  else
    target_user=$(whoami)
  fi

  # Garante que temos um usuário e que não é o root
  if [ -z "$target_user" ] || [ "$target_user" == "root" ]; then
    log_error "Não foi possível determinar um usuário não-root para adicionar ao grupo docker."
    exit 1
  fi
  log_info "Usuário alvo para o grupo docker: $target_user"

  # Cria o grupo 'docker' se ele não existir
  if ! getent group docker >/dev/null; then
    sudo groupadd docker
    log_info "Grupo 'docker' criado."
  fi

  sudo usermod -aG docker "$target_user"

  # Verifica se está rodando dentro de um contêiner Docker para o comportamento do systemctl
  if [ -f /.dockerenv ]; then
    log_info "Ambiente Docker detectado. Apenas habilitando o serviço."
    sudo systemctl enable docker
  else
    log_info "Ambiente real detectado. Habilitando e iniciando o serviço."
    sudo systemctl enable --now docker
  fi

  log_success "Docker pronto. (Lembre-se de deslogar para o grupo docker surtir efeito)"
}

main() {
  setup_yay
  atualizar_sistema
  instalar_programas
  configurar_asdf
  instalar_asdf_plugins
  install_docker

  log_success "Setup concluído com sucesso!"
}

main
