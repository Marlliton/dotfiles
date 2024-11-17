#!/bin/bash

RED=$'\e[0;31m'
RESET=$'\e[0m'

# Verificar se o stow está instalado
if ! command -v stow &> /dev/null; then
  echo "${RED}[ERRO] O stow não está instalado. Instalando automaticamente...${RESET}"
  sudo apt install stow -y

  # Verificar se a instalação foi bem-sucedida
  if ! command -v stow &> /dev/null; then
    echo "${RED}[FALHA] Não foi possível instalar o stow. Verifique sua conexão com a internet ou o gerenciador de pacotes.${RESET}"
    exit 1
  fi
  echo "[SUCESSO] O stow foi instalado com sucesso."
else
  echo "[OK] O stow já está instalado."
fi

# Continuar com o script
echo "[INFO] Continuando com o restante do script..."
# Adicione seus comandos aqui


CONFIG_DIRS=(
  "backgrounds"
  "kitty"
  "nvim"
  "tmux"
  "zshrc"
)
DOTFILES_DIR="$HOME/dotfiles"

cd "$DOTFILES_DIR" || exit 1

for dir in "${CONFIG_DIRS[@]}"; do
  echo "[SOTW] processando o diretório: $dir"
  stow -v "$dir" -t "$HOME"
done

echo "[INFO] Processo de cofniguração de links simbólicos finalizado"
