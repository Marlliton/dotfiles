if status is-interactive
    # Commands to run in interactive sessions can go here

  # load ASDF and completions
  source ~/.asdf/asdf.fish
  source ~/.asdf/completions/asdf.fish

  alias update-nvim-stable='asdf uninstall neovim stable; and asdf install neovim stable'
  alias update-nvim-nightly='asdf uninstall neovim nightly; and asdf install neovim nightly'
  alias update-nvim-master='asdf uninstall neovim ref:master; and asdf install neovim ref:master'

  # CARGO
  set -gx PATH "$HOME/.cargo/bin" $PATH
  
  # RUST ALTERNATIVES
  alias ls="exa --icons"
  alias ll="exa --icons -l"
  alias la="exa --icons -la"
  alias cat="bat --style=auto"

  # GO (Golang) configuration
  if test -f ~/.asdf/plugins/golang/set-env.fish
      source ~/.asdf/plugins/golang/set-env.fish
  end

  # Add Go binaries to PATH
  set -gx PATH "$HOME/.asdf/installs/golang/(asdf current golang | awk '{print $2}')/bin" $PATH
  
  starship init fish | source

  zoxide init fish | source

  fzf --fish | source
  # CARREGAR O PLUGIN FZF.FISH (se estiver usando fisher)
  if type -q fzf_key_bindings
      fzf_key_bindings
  end

end
