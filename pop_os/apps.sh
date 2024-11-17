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

  if ! command -v ulauncher >/dev/null 2>&1; then
    echo "${YELLOW}INSTALANDO U_LAUNCHER${RESET}"
    caminho_u_launcher_instalacao="$PWD/u_launcher/index.sh"
    . "$caminho_u_launcher_instalacao"
  fi
  
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
  )

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

  # Para o Node.js
  if ! asdf list nodejs >/dev/null 2>&1; then
    echo "[INSTALANDO] Node.js"
    asdf install nodejs latest
    asdf global nodejs latest
  else
    echo "[NODEJS JÁ ESTÁ INSTALADO]"
  fi

  # Para o Neovim
  if ! asdf list neovim >/dev/null 2>&1; then
    echo "[INSTALANDO] Neovim"
    asdf install neovim stable
    asdf global neovim stable
  else
    echo "[NEOVIM JÁ ESTÁ INSTALADO]"
  fi

  # Para o Golang
  if ! asdf list golang >/dev/null 2>&1; then
    echo "[INSTALANDO] Golang"
    asdf install golang latest
    asdf global golang latest
  else
    echo "[GOLANG JÁ ESTÁ INSTALADO]"
  fi

  # Para o Python
  if ! asdf list python >/dev/null 2>&1; then
    echo "[INSTALANDO] Python"
    echo "[INFO] instalndon dependeincias do asdf Python"
    sudo apt update; sudo apt install build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev curl git \
        libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev 

    asdf install python latest
    asdf global python latest
  else
    echo "[PYTHON JÁ ESTÁ INSTALADO]"
  fi
}

instalar_apps_via_git_go_e_curl() {
  ( 
    cd ~    
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

# atualizar_sistema
# baixar_e_instalar_programas_apt
# Adicionando links simbólicos
symbolic_links="$PWD/symbolic_link.sh"
. "$symbolic_links"

instalar_asdf
adicionar_asdf_plugins
instalar_asdf_apps

instalar_apps_via_git_go_e_curl

echo "todos os aplicativos foram instalados"
