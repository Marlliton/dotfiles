#!/bin/bash

RED=$'\e[0;31m'
GREEN=$'\e[0;32m'
YELLOW=$'\e[0;33m'
BLUE=$'\e[0;34m'
RESET=$'\e[0m'

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
  "zsh"
  "ripgrep"
)

atualizar_sistema() {
  sudo apt update && sudo apt full-upgrade -y
}

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
}

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

instalar_asdf() {
  if [ ! -d "$HOME/.asdf" ]; then
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.1
  else 
    echo "ASDF já está instalado"
  fi
}

# Adicionar plugins ao asdf
adicionar_asdf_plugins() {
  echo "[ADICIONANDO PLUGINS AO ASDF]"

  plugins=(
    "nodejs https://github.com/asdf-vm/asdf-nodejs.git"
    "neovim"
    "golang https://github.com/asdf-community/asdf-golang.git"
    "python"
    "dart https://github.com/patoconnor43/asdf-dart.git"
    "rust https://github.com/asdf-community/asdf-rust.git"
  )

  if ! command -v asdf >/dev/null 2>&1; then
    echo "Adicionando temporariamente o ASDF as PATH"
    [ -f "$HOME/.asdf/asdf.sh" ] && . "$HOME/.asdf/asdf.sh"
  fi

  for plugin in "${plugins[@]}"; do
    plugin_name=$(echo "$plugin" | awk '{print $1}')
    if ! asdf plugin list | grep -q "^$plugin_name\$"; then
      echo "[ADICIONANDO PLUGIN] $plugin_name"
      asdf plugin add $plugin
    else
      echo "[PLUGIN < $plugin_name > JÁ EXISTE]"
    fi
  done
}

instalar_asdf_apps() {
  echo "[INSTALANDO VERSÕES COM ASDF]"

  # Para o Rust.js
    echo "[INSTALANDO] Rust"
    asdf install rust latest
    asdf global rust latest
    if ! command -v cargo >/dev/null 2>&1; then
      echo "Adicionando temporariamente o Cargo ao PATH"
      export PATH="$HOME/.cargo/bin:$PATH"
    fi

  # Para o Node.js
    echo "[INSTALANDO] Node.js"
    asdf install nodejs latest
    asdf global nodejs latest

  # Para o Neovim
    echo "[INSTALANDO] Neovim"
    asdf install neovim stable
    asdf global neovim stable

  # Para o Golang
    echo "[INSTALANDO] Golang"
    asdf install golang latest
    asdf global golang latest

  # Para o Python
    echo "[INSTALANDO] Python"
    echo "[INFO] instalndon dependeincias do asdf Python"
    sudo apt update; sudo apt install build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev curl git \
        libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev 

    asdf install python latest
    asdf global python latest
}

instalar_apps_via_git_go_e_curl() {
  ( 
    cd ~    

    #####
    # Instala o ho_my_zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    # Link simbólico com o zshrc pessoal
    if [ -f "~/.zshrc" ]; then
      echo "Deletando ZSHRC"
      rm "~/.zshrc"
      stow "~/dotfiles/zshrc"
      echo "ZSHRC substituido com sucesso."
    fi
    #####

    # Instala o oh-my-posh
    echo "Instalando oh-my-posh..."
    curl -fsSL https://ohmyposh.dev/install.sh | bash -s || { echo "Erro ao instalar oh-my-posh"; exit 1; }


    # Instala o Kitty
    echo "Instalando Kitty..."
    curl -fsSL https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin || { echo "Erro ao instalar Kitty"; exit 1; }

    # Clona o TPM do tmux
    echo "Clonando o TPM para o tmux..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm || { echo "Erro ao clonar o TPM"; exit 1; }

    echo "Baixando e instalando lazygit..."
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit -D -t /usr/local/bin/
    
    # Instala o delve
    echo "Instalando Delve..."
    go install github.com/go-delve/delve/cmd/dlv@latest
    
    # Reshima o Golang com asdf
    echo "Reshima o Golang..."
    asdf reshim golang 
  )
}
instalar_apps_cargo() {
  echo "[CARGO] instalando apps {exa, bat}"
  cargo install exa bat 
}

atualizar_sistema
baixar_e_instalar_programas_apt

# Adicionando links simbólicos
symbolic_links="$PWD/symbolic_link.sh"
. "$symbolic_links"

instalar_asdf
adicionar_asdf_plugins
instalar_asdf_apps

instalar_apps_cargo

instalar_apps_via_git_go_e_curl

echo "todos os aplicativos foram instalados"
