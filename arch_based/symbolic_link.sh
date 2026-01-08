#!/bin/bash

RED=$'\e[0;31m'
BLUE=$'\e[0;34m'
RESET=$'\e[0m'

# 1. Verificar e instalar o stow usando pacman
if ! command -v stow &> /dev/null; then
  echo "${RED}[ERRO] O stow não está instalado. Instalando...${RESET}"
  # No Arch usamos pacman -S
  sudo pacman -S --noconfirm stow

  if ! command -v stow &> /dev/null; then
    echo "${RED}[FALHA] Não foi possível instalar o stow.${RESET}"
    exit 1
  fi
  echo "[SUCESSO] O stow foi instalado com sucesso."
else
  echo "[OK] O stow já está instalado."
fi

# 2. Configurações de diretório
# Usar PWD garante que se você rodar o script de dentro da pasta, ele funcionará mesmo que não se chame "dotfiles"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CONFIG_DIRS=(
  "backgrounds"
  "kitty"
  "nvim"
  "tmux"
  "zshrc"
)

cd "$DOTFILES_DIR" || { echo "${RED}Erro ao acessar $DOTFILES_DIR${RESET}"; exit 1; }

# 3. Execução do Stow
for dir in "${CONFIG_DIRS[@]}"; do
  if [ -d "$dir" ]; then
    echo "${BLUE}[STOW] linkando: $dir -> $HOME ${RESET}"
    # O comando stow -R (restow) é melhor, pois ele remove links quebrados antigos e refaz
    stow -R -v "$dir" -t "$HOME"
  else
    echo "${RED}[AVISO] Diretório $dir não encontrado em $DOTFILES_DIR${RESET}"
  fi
done

echo "[INFO] Processo de configuração de links simbólicos finalizado"
