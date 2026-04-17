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
# Load ASDF Go environment if available
if test -f ~/.asdf/plugins/golang/set-env.fish
    source ~/.asdf/plugins/golang/set-env.fish
end

# ------------------------------------------------------------------------------
# Aliases (CLI quality of life)
# ------------------------------------------------------------------------------
alias ls="exa --icons"
alias ll="exa --icons -l"
alias la="exa --icons -la"
alias cat="bat --style=auto"

# ------------------------------------------------------------------------------
# Environment variables
# ------------------------------------------------------------------------------
# set -gx EXAMPLE gpt-4o

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
