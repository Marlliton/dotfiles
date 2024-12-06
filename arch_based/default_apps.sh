
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

PROGRAMAS_YAY=(
  "hyprshot"
  "swaync"
  "hyprlock"
  "hypridle"
  "hyprpaper"
  "ttf-cascadia-code-nerd"
  "nwg-look"
  "catppuccin-gtk-theme-mocha"
)

PROGRAMAS_PACMAN=(
  "git"
  "curl"
  "unzip"
  "gparted"
  "keepassxc"
  "stow"
  "zsh"
  "ripgrep" 
  "gimp"
  "hyprland"
  "waybar"
  "kitty"
  "wofi"
  "dolphin"
  "flatpak" 
  "openssh"
  "tmux"
  "wl-clipboard"
  "github-cli"
  "vim"
  # audio e video
  "pavucontrol"
  "handbrake"
  "vlc"
  "gst-libav"
  "gst-plugins-bad"
  "gst-plugins-good"
  "gst-plugins-ugly"
  "ffmpeg"
  "gstreamer"
  # portais
  "xdg-desktop-portal"
  "xdg-desktop-portal-hyprland"
  "archlinux-xdg-menu"
)

atualizar_sistema() {
  sudo pacman -Syu --noconfirm
}

baixar_e_instalar_programas_pacman() {
  for programa in "${PROGRAMAS_PACMAN[@]}";
  do
    if ! pacman -Qi "$programa" >/dev/null 2>&1; then
      echo "${BLUE}[INSTALANDO] $programa via [PACMAN]${RESET}"
      sudo pacman -S "$programa" --noconfirm
    else 
      echo "${BLUE}[PROGRAMA < $programa > JÁ EXISTE]${RESET}"
    fi
  done
}

baixar_e_instalar_programas_flatpak() {
  if ! command -v flatpak >/dev/null 2>&1; then
    sudo pacman -S flatpak --noconfirm
  fi

  for programa in "${PROGRAMAS_FLATPAK[@]}"
  do
    if ! flatpak list | grep -q "$programa"; then
      # Instalando programa
      echo "${BLUE}[INSTALANDO] $programa:${RESET}"
      flatpak install flathub "$programa" -y
    else
      echo "${BLUE}[PROGRAMA < $programa > JÁ EXISTE]${RESET}"
    fi
  done
}

instalar_asdf() {
  if [ ! -d "$HOME/.asdf" ]; then
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.1
  else 
    echo "${YELLOW}ASDF já está instalado${RESET}"
  fi
}

# Adicionar plugins ao asdf
adicionar_asdf_plugins() {
  echo "${BLUE}[ADICIONANDO PLUGINS AO ASDF]${RESET}"

  plugins=(
    "nodejs https://github.com/asdf-vm/asdf-nodejs.git"
    "neovim"
    "golang https://github.com/asdf-community/asdf-golang.git"
    "python"
    "dart https://github.com/patoconnor43/asdf-dart.git"
    "rust https://github.com/asdf-community/asdf-rust.git"
  )

  if ! command -v asdf >/dev/null 2>&1; then
    echo "${YELLOW}Adicionando temporariamente o ASDF as PATH${RESET}"
    [ -f "$HOME/.asdf/asdf.sh" ] && . "$HOME/.asdf/asdf.sh"
  fi

  for plugin in "${plugins[@]}"; do
    plugin_name=$(echo "$plugin" | awk '{print $1}')
    if ! asdf plugin list | grep -q "^$plugin_name\$"; then
      echo "${BLUE}[ADICIONANDO PLUGIN] $plugin_name ${RESET}"
      asdf plugin add $plugin
    else
      echo "${YELLOW}[PLUGIN < $plugin_name > JÁ EXISTE]${RESET}"
    fi
  done
}

instalar_asdf_apps() {
  echo "${BLUE}[INSTALANDO VERSÕES COM ASDF]${RESET}"

  # Para o Rust.js
    echo "${YELLOW}[INSTALANDO] Rust${RESET}"
    asdf install rust latest
    asdf global rust latest
    if ! command -v cargo >/dev/null 2>&1; then
      echo "${RED}Adicionando temporariamente o Cargo ao PATH${RESET}"
      export PATH="$HOME/.cargo/bin:$PATH"
    fi
    echo "${GREEN}[SUCESSO] Rust instaldo${RESET}"

  # Para o Node.js
    echo "${YELLOW}[INSTALANDO] Node.js${RESET}"
    asdf install nodejs latest
    asdf global nodejs latest
    echo "${GREEN}[SUCESSO] Node.js instaldo${RESET}"

  # Para o Neovim
    echo "${YELLOW}[INSTALANDO] Neovim${RESET}"
    asdf install neovim stable
    asdf global neovim stable
    echo "${GREEN}[SUCESSO] Neovim instaldo${RESET}"

  # Para o Golang
    echo "${YELLOW}[INSTALANDO] Golang${RESET}"
    asdf install golang latest
    asdf global golang latest
    echo "${GREEN}[SUCESSO] Golang instaldo${RESET}"

  # Para o Python
    echo "${YELLOW}[INSTALANDO] Python${RESET}"
    echo "${RED}[INFO] instalndon dependeincias do asdf Python${RESET}"
    sudo pacman -S --needed base-devel zlib openssl xz tk sqlite3 libffi

    asdf install python latest
    asdf global python latest
    
    echo "${GREEN}[SUCESSO] Python instaldo${RESET}"
}

instalar_apps_via_git_go_e_curl() {
  ( 
    cd ~    

    #####
    # Instala o ho_my_zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    # Link simbólico com o zshrc pessoal
    #####

    echo "Clonando ZSH-SYNTAX-HIGHLIGHTING"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

    echo "Clonando ZSH-AUTOSUGGESTIONS"
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

    # Instala o oh-my-posh
    echo "Instalando oh-my-posh..."
    curl -fsSL https://ohmyposh.dev/install.sh | bash -s || { echo "Erro ao instalar oh-my-posh"; exit 1; }

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
deletar_lixo() {
  echo "${YELLOW}Verificando se o zshrc existe${RESET}"
  if [ -f "$HOME/.zshrc" ]; then
    echo "${RED}Deletando ZSHRC${RESET}"
    rm "$HOME/.zshrc"

    cd "$HOME/dotfiles"

    stow zshrc
    echo "${GREEN}ZSHRC substituido com sucesso.${RESET}"
  fi


  # Verificar se o diretório lazygit existe e removê-lo
  if [ -d "$HOME/lazygit" ]; then
    echo "Removendo diretório lazygit..."
    rm -rf "$HOME/lazygit"
  fi

  # Verificar se o arquivo lazygit.tar.gz existe e removê-lo
  if [ -f "$HOME/lazygit.tar.gz" ]; then
    echo "Removendo arquivo lazygit.tar.gz..."
    rm "$HOME/lazygit.tar.gz"
  fi
}

atualizar_sistema
baixar_e_instalar_programas_pacman

# Adicionando links simbólicos
symbolic_links="$PWD/symbolic_link.sh"
. "$symbolic_links"

instalar_asdf
adicionar_asdf_plugins
instalar_asdf_apps

instalar_apps_cargo

instalar_apps_via_git_go_e_curl

