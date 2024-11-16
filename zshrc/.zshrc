# WARN: Only in WSL
#export PATH=$PATH:/home/marlliton/.local/bin 

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# THEMES
# ZSH_THEME="powerlevel10k/powerlevel10k"
# THEMES

# PLUGINS
plugins=(
	git
  zsh-autosuggestions
	zsh-syntax-highlighting
	z
)
# PLUGINS

# LOAD oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"

source $ZSH/oh-my-zsh.sh
# LOAD oh-my-zsh

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
# alias air=~/.asdf/installs/golang/1.23.0/bin/air
# GO

# LOAD PRIVATE TOKENS
if [ -f ~/dotfiles/zshrc/.zshrc.private ]; then
	source ~/dotfiles/zshrc/.zshrc.private
fi
# LOAD PRIVATE TOKENS

# CARGO
export PATH="$HOME/.cargo/bin:$PATH"
# CARGO

# RUST ALTERNATIVES
alias ls="exa --icons"
alias ll="exa --icons -l"
alias la="exa --icons -la"
alias cat="bat --style=auto"
# RUST ALTERNATIVES

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

eval "$(oh-my-posh init zsh --config ~/dotfiles/zshrc/ho_my_posh.json)"
