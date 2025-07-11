if status is-interactive
  # Commands to run in interactive sessions can go here

  # private envs (if file "envs" exists)
  set envs_file (status dirname)/envs
  if test -f $envs_file
    source $envs_file
  end

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
  # set golang_version (asdf where golang)
  # set -gx PATH "$(asdf where golang)/bin" $PATH
  
  starship init fish | source

  zoxide init fish | source
end
