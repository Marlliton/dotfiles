#!/bin/bash

# Garante que o script pare em caso de erro
set -e

# Obtém o diretório onde o próprio script está localizado, para referenciar outros scripts de forma segura
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# INSTALL DEFAULT APPS
# Usa o SCRIPT_DIR como base para garantir que o caminho esteja sempre correto
. "$SCRIPT_DIR/default_apps.sh"
. "$SCRIPT_DIR/symbolic_link.sh"
