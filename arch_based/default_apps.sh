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
  "waybar" "jq" "pavucontrol" "openssl" "zlib" "xz" "tk" "zstd" "greetd-regreet" "hyprland"
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

post_install_docker() {
  log_step "Configurando Docker..."

  # -------------------------------
  # Determina o usuário alvo
  # -------------------------------
  local target_user
  if [ -n "$SUDO_USER" ]; then
    target_user="$SUDO_USER"
  elif [ -n "$USER" ]; then
    target_user="$USER"
  else
    target_user="$(whoami)"
  fi

  if [ -z "$target_user" ] || [ "$target_user" = "root" ]; then
    log_error "Não foi possível determinar um usuário não-root para o grupo docker."
    return 1
  fi
  log_info "Usuário alvo para o grupo docker: $target_user"

  # -------------------------------
  # Grupo docker
  # -------------------------------
  if ! getent group docker >/dev/null; then
    sudo groupadd docker
    log_info "Grupo 'docker' criado."
  fi

  sudo usermod -aG docker "$target_user"

  # -------------------------------
  # Detecta ambiente (container / VM / físico)
  # -------------------------------
  local virt_type
  # Tenta detectar a virtualização com systemd-detect-virt
  if command -v systemd-detect-virt >/dev/null; then
    virt_type=$(systemd-detect-virt)
  else
    virt_type="none"
  fi

  # Se o método acima retornou "none", tenta um fallback via DMI/sysfs, que é mais confiável em alguns cenários de VM.
  if [ "$virt_type" = "none" ]; then
    if [ -f /sys/class/dmi/id/product_name ] && \
       grep -q -i -E 'kvm|qemu|virtualbox|vmware' /sys/class/dmi/id/product_name 2>/dev/null; then
      virt_type="vm" # Define um tipo genérico de VM para evitar a classificação como "máquina física"
    fi
  fi

  if [ "$virt_type" = "docker" ] || [ -f /.dockerenv ]; then
    log_warn "Container Docker detectado. Pulando start do serviço."
    sudo systemctl enable docker

  elif [ "$virt_type" != "none" ]; then
    # -------------------------------
    # Máquina Virtual
    # -------------------------------
    log_warn "Ambiente virtualizado detectado ($virt_type)."
    log_warn "Pulando ativação de docker"
  else
    # -------------------------------
    # Máquina física
    # -------------------------------
    log_info "Máquina física detectada. Habilitando e iniciando Docker."
    sudo systemctl enable --now docker
  fi

  log_success "Docker configurado com sucesso."
  log_info "Deslogue e logue novamente para aplicar o grupo docker."
}

configurar_display_manager() {
  log_step "Configurando Display Manager (greetd + Hyprland)..."

  # Garante que o diretório de configuração do greetd exista
  sudo mkdir -p /etc/greetd

  log_info "Criando configuração do Hyprland para o greetd em /etc/greetd/hyprland.conf"
  # 1. Cria um arquivo de configuração específico para o Hyprland rodar o ReGreet
  cat <<EOF | sudo tee /etc/greetd/hyprland.conf
# Configuração do Hyprland para a tela de login (greetd)
# Executa o ReGreet e, em seguida, fecha esta instância do Hyprland
exec-once = regreet; hyprctl dispatch exit
misc {
    disable_hyprland_logo = true
    disable_splash_rendering = true
    disable_hyprland_guiutils_check = true
}
EOF

  log_info "Criando configuração principal do greetd em /etc/greetd/config.toml"
  # 2. Configura o greetd para usar a instância do Hyprland acima como a tela de login
  cat <<EOF | sudo tee /etc/greetd/config.toml
[default_session]
# Usa o script 'start-hyprland' para iniciar com a configuração específica do greeter
command = "start-hyprland -- -c /etc/greetd/hyprland.conf"
user = "greeter"
EOF

  log_info "Arquivos de configuração em /etc/greetd/ criados."

  # 3. Habilita o serviço do greetd para iniciar no boot do sistema real
  if [ ! -f /.dockerenv ]; then
    log_info "Habilitando serviço greetd.service para o próximo boot."
    sudo systemctl enable greetd.service
  else
    log_warn "Ambiente Docker detectado, pulando a habilitação do serviço greetd."
  fi

  log_success "Display Manager configurado para usar Hyprland + ReGreet."
}

main() {
  setup_yay
  atualizar_sistema
  instalar_programas
  configurar_asdf
  instalar_asdf_plugins
  configurar_display_manager
  post_install_docker

  log_success "Setup concluído com sucesso!"
}

main
