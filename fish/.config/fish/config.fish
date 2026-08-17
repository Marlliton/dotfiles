# ------------------------------------------------------------------------------
# Interactive shell only
# ------------------------------------------------------------------------------
if not status is-interactive
    exit
end

# ------------------------------------------------------------------------------
# Private environment variables
# ------------------------------------------------------------------------------
# Loads ./envs if the file exists (ignored by git, usually secrets/local config)
set envs_file (status dirname)/envs
if test -f $envs_file
    source $envs_file
end

# ------------------------------------------------------------------------------
# ASDF
# ------------------------------------------------------------------------------
# Resolve ASDF shims directory
if test -z "$ASDF_DATA_DIR"
    set asdf_shims "$HOME/.asdf/shims"
else
    set asdf_shims "$ASDF_DATA_DIR/shims"
end

# Prepend ASDF shims to PATH without reordering existing entries
if not contains $asdf_shims $PATH
    set -gx --prepend PATH $asdf_shims
end
set --erase asdf_shims

# ASDF helpers
alias update-nvim-stable='asdf uninstall neovim stable; and asdf install neovim stable'
alias update-nvim-nightly='asdf uninstall neovim nightly; and asdf install neovim nightly'
alias update-nvim-master='asdf uninstall neovim ref:master; and asdf install neovim ref:master'

# ------------------------------------------------------------------------------
# PATH additions
# ------------------------------------------------------------------------------
# Cargo / Rust
if not contains "$HOME/.cargo/bin" $PATH
    set -gx PATH "$HOME/.cargo/bin" $PATH
end

# User local binaries
if not contains "$HOME/.local/bin" $PATH
    set -gx PATH "$HOME/.local/bin" $PATH
end

# ------------------------------------------------------------------------------
# Go (Golang)
# ------------------------------------------------------------------------------
# Load ASDF Go environment if available (define GOROOT/GOPATH/GOBIN por versão)
if test -f ~/.asdf/plugins/golang/set-env.fish
    source ~/.asdf/plugins/golang/set-env.fish
end

# O set-env.fish do asdf aponta GOBIN para ~/.asdf/installs/golang/<versao>/bin,
# o que faz as ferramentas instaladas com `go install` sumirem a cada upgrade do Go.
# Este handler é registrado depois do dele, então roda por último e vence.
function pin_gobin --on-event fish_prompt
    set -gx GOBIN "$HOME/.local/bin"
end

# ------------------------------------------------------------------------------
# Aliases (CLI quality of life)
# ------------------------------------------------------------------------------
alias ls="exa --icons=auto"
alias ll="exa --icons=auto -l"
alias la="exa --icons=auto -la"
alias cat="bat --style=auto"

# ------------------------------------------------------------------------------
# Environment variables
# ------------------------------------------------------------------------------
# set -gx EXAMPLE gpt-4o
set -gx ANDROID_HOME $HOME/Android/Sdk
set -gx ANDROID_SDK_ROOT $HOME/Android/Sdk
set -gx JAVA_HOME /usr/lib/jvm/java-17-openjdk

# ATENÇÃO: nunca usar "a:b:$PATH" aqui. No fish o PATH é uma lista, e concatenar
# com ":" faz produto cartesiano (cada entrada existente vira "a:b:entrada"),
# multiplicando o PATH a cada shell até estourar o limite do exec (E2BIG).
# fish_add_path prepende cada caminho como elemento e não duplica.
fish_add_path -gP $ANDROID_HOME/cmdline-tools/latest/bin $ANDROID_HOME/platform-tools $ANDROID_HOME/emulator

# ------------------------------------------------------------------------------
# SSH agent (passphrase cached once per session)
# ------------------------------------------------------------------------------
# Point to the systemd user ssh-agent socket. Combined with `AddKeysToAgent yes`
# in ~/.ssh/config, the key is unlocked on first use and reused for the whole
# session. Also set session-wide in ~/.config/environment.d/ssh-agent.conf; this
# guard sets it immediately for terminals opened before the next login.
if test -z "$SSH_AUTH_SOCK"; and test -n "$XDG_RUNTIME_DIR"
    set -gx SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/ssh-agent.socket"
end

# ------------------------------------------------------------------------------
# Prompt & shell enhancements
# ------------------------------------------------------------------------------
starship init fish | source
fzf --fish | source
zoxide init fish | source

# ------------------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------------------
function codex-marlliton
    env CODEX_HOME=$HOME/.codex-marlliton codex $argv
end

function codex-cod3r
    env CODEX_HOME=$HOME/.codex-cod3r codex $argv
end

# pnpm
set -gx PNPM_HOME "/home/marlliton/.local/share/pnpm"
if not string match -q -- "$PNPM_HOME/bin" $PATH
  set -gx PATH "$PNPM_HOME/bin" $PATH
end
# pnpm end
