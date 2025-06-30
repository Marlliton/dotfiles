#!/bin/bash

source ./logging.sh # import logs

set -e  # Interrompe o script em caso de erro

PROGRAMAS_FLATPAK=(
  "com.discordapp.Discord"
  "io.beekeeperstudio.Studio"
  "org.flameshot.Flameshot"
  "com.obsproject.Studio"
)

PROGRAMAS_APT=(
  "git"
  "curl"
  "unzip"
  "gparted"
  "keepassxc"
  "stow"
  "fzf"
  "ripgrep"
  "gimp"
  "handbrake"
  "audacious"
  "alacarte"
  "xclip"
  "tmux"
  "vlc"
  "libpng-dev"
  "libjpeg-dev"
  "libtiff-dev"
  "imagemagick"
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

  sudo add-apt-repository ppa:fish-shell/release-4
  sudo apt update
  sudo apt install fish -y
}

gerar_links() {
  symbolic_links="$PWD/symbolic_link.sh"
  . "$symbolic_links"
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

instalar_go_apps() {
  log_step "Instalando Delve..."
  go install github.com/go-delve/delve/cmd/dlv@latest || { log_error "Erro ao instalar Delve"; exit 1; }
  log_success "Delve instalado com sucesso"

  log_step "Reshimando o Golang com asdf..."
  asdf reshim golang || { log_error "Erro ao reshimar o Golang"; exit 1; }
  log_success "Golang reshimado com sucesso"

  log_step "Instalando golang migrate"
  version=v4.18.3
  os=linux
  arch=amd64

  curl -L https://github.com/golang-migrate/migrate/releases/download/$version/migrate.$os-$arch.tar.gz | tar xvz
  sudo mv migrate /usr/local/bin/
  log_success "Migrate instalado com sucesso"
}

instalar_apps_via_web() {
  ( 
    cd ~    

    # log_step "Instalando oh-my-zsh..."
    # sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || { log_error "Erro ao instalar oh-my-zsh"; exit 1; }
    # log_success "oh-my-zsh instalado com sucesso"
    #
    # log_step "Instalando oh-my-posh..."
    # curl -fsSL https://ohmyposh.dev/install.sh | bash -s || { log_error "Erro ao instalar oh-my-posh"; exit 1; }
    # log_success "oh-my-posh instalado com sucesso"

    log_step "Instalando Kitty..."
    curl -fsSL https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin || { log_error "Erro ao instalar Kitty"; exit 1; }
    log_success "Kitty instalado com sucesso"

    log_step "Clonando o TPM para o tmux..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm || { log_error "Erro ao clonar o TPM"; exit 1; }
    log_success "TPM clonado com sucesso"

    log_step "Baixando e instalando lazygit..."
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit -D -t /usr/local/bin/ || { log_error "Erro ao instalar lazygit"; exit 1; }
    log_success "Lazygit instalado com sucesso"

    # log_step "Instalando zsh-autosuggestions..."
    # git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions || { log_error "Erro ao instalar zsh-autosuggestions"; exit 1; }
    # log_success "zsh-autosuggestions instalado com sucesso"
    #
    # log_step "Instalando zsh-syntax-highlighting..."
    # git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting || { log_error "Erro ao instalar zsh-syntax-highlighting"; exit 1; }
    # log_success "zsh-syntax-highlighting instalado com sucesso"
  )
}
instalar_apps_cargo() {
  log_step "Instalando cargo [exa, bat]..."
  cargo install exa bat 
  log_success "Apps [exa, bat] instalados com sucesso."
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

  gerar_links

  instalar_flatpak

  instalar_asdf
  carregar_asdf
  adicionar_asdf_plugins
  instalar_asdf_apps 

  instalar_apps_cargo

  instalar_apps_via_web

  instalar_go_apps

  install_docker
  log_success "Instalação concluída."
}

main
