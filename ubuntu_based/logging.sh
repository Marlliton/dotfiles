# Cores para os logs
RED=$'\e[0;31m'
GREEN=$'\e[0;32m'
YELLOW=$'\e[0;33m'
BLUE=$'\e[0;34m'
MAGENTA=$'\e[0;35m'
CYAN=$'\e[0;36m'
RESET=$'\e[0m'

# Configuração de logs
LOG_FILE="install_$(date +%Y-%m-%d_%H-%M-%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

# Funções de log melhoradas
log() {
    local level="$1"
    local color="$2"
    local message="$3"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "${color}[${timestamp}] [${level}] ${message}${RESET}"
}

log_info() { log "INFO" "${BLUE}" "$1"; }
log_warn() { log "WARN" "${YELLOW}" "$1"; }
log_error() { log "ERROR" "${RED}" "$1"; }
log_success() { log "SUCCESS" "${GREEN}" "$1"; }
log_debug() { log "DEBUG" "${MAGENTA}" "$1"; }
log_step() { log "STEP" "${CYAN}" "$1"; }
