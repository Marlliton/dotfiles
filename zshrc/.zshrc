# Verifica se ~/.local/bin já está no PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

export SHELL=$(which zsh)

# Verifica se ~/.local/kitty.app/bin já está no PATH
if [[ ":$PATH:" != *":$HOME/.local/kitty.app/bin:"* ]]; then
  export PATH="$HOME/.local/kitty.app/bin:$PATH"
fi

# PLUGINS
plugins=(
	git
  zsh-autosuggestions
	zsh-syntax-highlighting
	z
)
# PLUGINS

# LOAD OH MY ZSH
export ZSH="$HOME/.oh-my-zsh"

source $ZSH/oh-my-zsh.sh
# LOAD OH MY ZSH

# HYPRSHOT_DIR
# export HYPRSHOT_DIR="$HOME/Pictures/screenshot"
# HYPRSHOT_DIR

# ASDF
. "$HOME/.asdf/asdf.sh"
. "$HOME/.asdf/completions/asdf.bash"

alias update-nvim-stable='asdf uninstall neovim stable && asdf install neovim stable'
alias update-nvim-nightly='asdf uninstall neovim nightly && asdf install neovim nightly'
alias update-nvim-master='asdf uninstall neovim ref:master && asdf install neovim ref:master'
# ASDF

# GO
. ~/.asdf/plugins/golang/set-env.zsh
export PATH="$HOME/.asdf/installs/golang/1.23.0/bin:$PATH"
# GO

# LOAD PRIVATE TOKENS
if [ -f ~/dotfiles/zshrc/.zshrc.private ]; then
	source ~/dotfiles/zshrc/.zshrc.private
fi
# LOAD PRIVATE TOKENS

# LOAD TEMP VARIABLES
if [ -f ~/dotfiles/zshrc/.zshrc.temp ]; then
	source ~/dotfiles/zshrc/.zshrc.temp
fi
# LOAD TEMP VARIABLES

# CARGO
export PATH="$HOME/.cargo/bin:$PATH"
# CARGO

# RUST ALTERNATIVES
alias ls="exa --icons"
alias ll="exa --icons -l"
alias la="exa --icons -la"
alias cat="bat --style=auto"
# RUST ALTERNATIVES

eval "$(oh-my-posh init zsh --config ~/dotfiles/zshrc/ho_my_posh.json)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
