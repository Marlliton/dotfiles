#!/bin/bash

# Cores para saída
RED=$'\e[0;31m'
BLUE=$'\e[0;34m'
GREEN=$'\e[0;32m'
RESET=$'\e[0m'

# 1. Verificar e instalar o GNU Stow
if ! command -v stow &>/dev/null; then
  echo "${BLUE}[INFO] O stow não está instalado. Sincronizando repositórios e instalando...${RESET}"

  sudo pacman -Sy --noconfirm stow

  if [ $? -ne 0 ]; then
    echo "${RED}[FALHA] Não foi possível instalar o stow. Verifique sua conexão ou permissões sudo.${RESET}"
    exit 1
  fi
  echo "${GREEN}[SUCESSO] O stow foi instalado com sucesso.${RESET}"
else
  echo "${GREEN}[OK] O stow já está instalado.${RESET}"
fi

# 2. Configurações de diretório
# Define o caminho absoluto da pasta raiz dos dotfiles (um nível acima do script)
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Lista de pastas a serem linkadas
CONFIG_DIRS=(
  "backgrounds"
  "kitty"
  "nvim"
  "tmux"
  "fish"
  "hypr"
  "rofi"
  "starship"
  "swappy"
  "waybar"
  "xdg-desktop-portal"
)

# Move para o diretório dos dotfiles
cd "$DOTFILES_DIR" || {
  echo "${RED}Erro ao acessar $DOTFILES_DIR${RESET}"
  exit 1
}

# 3. Execução do Stow
echo "${BLUE}Iniciando a criação de links simbólicos em $HOME...${RESET}"

for dir in "${CONFIG_DIRS[@]}"; do
  if [ -d "$dir" ]; then
    echo "${BLUE}[STOW] Linkando: $dir${RESET}"

    # -R (restow): Remove links antigos e refaz (bom para atualizações)
    # -v (verbose): Mostra o que está sendo feito
    # -t (target): Define o destino (geralmente a Home)
    stow -R -v -t "$HOME" "$dir"
  else
    echo "${RED}[AVISO] Diretório '$dir' não encontrado em $DOTFILES_DIR${RESET}"
  fi
done

echo "${GREEN}[PRONTO] Configuração de links simbólicos finalizada!${RESET}"
