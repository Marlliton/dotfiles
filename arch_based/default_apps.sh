#!/bin/bash

# Obtém o diretório onde o próprio script está localizado para referenciar outros scripts de forma segura
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "$SCRIPT_DIR/logging.sh"

set -e

PROGRAMAS_PACMAN=(
  # --- BASE DO SISTEMA & DRIVERS ---
  "hyprland" "sddm" "mesa" "polkit-gnome" "xdg-desktop-portal-hyprland"
  "xdg-desktop-portal-gtk" "archlinux-xdg-menu" "qt5-declarative"
  # --- DESENVOLVIMENTO & COMPILAÇÃO ---
  "base-devel" "git" "lazygit" "curl" "openssh" "openssl" "stow"
  "docker" "docker-compose" "jq" "tk" "zlib" "xz" "zstd"
  # --- TERMINAL MODERNO (CLI) ---
  "fish" "kitty" "starship" "tmux" "btop" "fzf" "ripgrep"
  "eza" "bat" "zoxide" "wl-clipboard" "fastfetch"
  # --- INTERFACE & APARÊNCIA (HYPRLAND) ---
  "waybar" "rofi" "dunst" "hyprpaper" "nwg-look" "kvantum"
  "pavucontrol" "grim" "slurp" "swappy"
  # --- FONTES & ÍCONES ---
  "otf-font-awesome" "ttf-firacode-nerd" "ttf-cascadia-code-nerd"
  "noto-fonts-emoji" "adwaita-icon-theme"
  # --- GERENCIAMENTO DE ARQUIVOS & DISCO ---
  "dolphin" "ark" "unzip" "unrar" "p7zip" "gparted" "dolphin-plugins"
  # --- APLICATIVOS (GUI) ---
  "firefox" "gedit" "keepassxc" "gimp" "kdenlive"
  "handbrake" "vlc" "audacious" "gwenview"
)

# Programas que vamos buscar no AUR
PROGRAMAS_AUR=(
  "asdf-vm" "qt6ct-kde" "catppuccin-gtk-theme-mocha"
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
  virt_type="$(systemd-detect-virt || true)"

  if [ "$virt_type" = "docker" ] || [ -f /.dockerenv ]; then
    log_warn "Container Docker detectado. Pulando start do serviço."
    sudo systemctl enable docker

  elif [ "$virt_type" != "none" ]; then
    # -------------------------------
    # Máquina Virtual
    # -------------------------------
    log_warn "Ambiente virtualizado detectado ($virt_type)."
    log_warn "Pulando ativaćão de docker"
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

configurar_sddm() {
  log_step "Configurando SDDM (Login Manager)..."

  # Detecta se estamos em um container para pular a ativação
  local virt_type
  virt_type="$(systemd-detect-virt || true)"

  if [ "$virt_type" = "docker" ] || [ -f /.dockerenv ]; then
    log_warn "Container Docker detectado. Pulando ativação do serviço sddm."
    return
  fi

  if systemctl is-enabled --quiet sddm; then
    log_warn "SDDM já está habilitado."
  else
    log_info "Habilitando serviço SDDM..."
    sudo systemctl enable sddm
  fi

  # Não iniciamos com --now para evitar que a sessão atual caia
  log_success "SDDM configurado. Ele será iniciado no próximo boot."
}

instalar_tmux_plugins() {
  log_step "Instalando plugins e ferramentas de sistema..."

  # 1. Instalação do tmux-copy-plugin via Go
  if command -v go >/dev/null 2>&1; then
    log_info "Instalando tmux-copy-plugin via Go..."
    if go install github.com/Marlliton/tmux-copy-plugin@v1.0.5; then
      # Executa reshim apenas se o asdf estiver presente
      if command -v asdf >/dev/null 2>&1; then
        log_info "Atualizando shims do asdf (golang)..."
        asdf reshim golang
      fi
    else
      log_error "Falha ao instalar tmux-copy-plugin."
    fi
  else
    log_warn "Go não encontrado. Pulando instalação do tmux-copy-plugin."
  fi

  # 2. Configuração do tema Catppuccin para Tmux
  local tmux_plugin_dir="$HOME/.config/tmux/plugins/catppuccin/tmux"

  if [ -d "$tmux_plugin_dir/.git" ]; then
    log_warn "Plugin Catppuccin já está instalado em $tmux_plugin_dir."
  else
    log_info "Clonando tema Catppuccin (v2.1.3)..."
    mkdir -p "$(dirname "$tmux_plugin_dir")"

    if git clone -b v2.1.3 https://github.com/catppuccin/tmux.git "$tmux_plugin_dir"; then
      log_success "Catppuccin clonado com sucesso."
    else
      log_error "Erro ao clonar o repositório do Catppuccin."
      return 1
    fi
  fi

  log_success "plugins instalados com sucesso!"
}

pos_instalacao() {
  # 3. Mudança de Shell para Fish
  log_step "Configurando Fish como shell padrão..."

  local fish_path
  fish_path=$(command -v fish)

  if [[ "$SHELL" == *"/fish" ]]; then
    log_warn "Fish já é o seu shell atual (\$SHELL)."
  else
    # Garante que o caminho do fish está no /etc/shells para o chsh não falhar
    if ! grep -q "$fish_path" /etc/shells; then
      log_info "Adicionando $fish_path ao /etc/shells..."
      echo "$fish_path" | sudo tee -a /etc/shells
    fi

    log_info "Alterando shell para $fish_path..."
    if sudo chsh -s "$fish_path" "$USER"; then
      log_success "Shell alterado! Reinicie sua máquina para aplicar."
    else
      log_error "Falha ao alterar o shell."
    fi
  fi

  log_success "Pós-instalação concluída!"
}

main() {
  setup_yay
  atualizar_sistema
  instalar_programas
  configurar_asdf
  instalar_asdf_plugins
  post_install_docker
  configurar_sddm
  instalar_tmux_plugins
  pos_instalacao

  log_success "Setup concluído com sucesso!"
}

main
