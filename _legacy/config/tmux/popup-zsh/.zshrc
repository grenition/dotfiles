# Load the regular interactive shell setup before adding popup-only behavior.
unset ZDOTDIR
[[ -r "$HOME/.zshrc" ]] && source "$HOME/.zshrc"
HISTFILE="$HOME/.zsh_history"

# Keep a lone Escape responsive while still allowing arrow-key sequences.
KEYTIMEOUT=5

function _tmux_popup_close() {
  exit
}

zle -N _tmux_popup_close
bindkey '\e' _tmux_popup_close
