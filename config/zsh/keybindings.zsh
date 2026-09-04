# macOS-style cursor and editing keys for the zsh line editor.
#
# Ghostty sends Option-key chords as Alt sequences (macos-option-as-alt) and
# maps Cmd+Left/Right/Backspace to Home/End/Ctrl+U (see config/ghostty).
# tmux passes all of these through to the shell. Sourced from ~/.zshrc by
# the repo install script.

bindkey -e

# Ctrl/Option + Left/Right move by word.
bindkey '\e[1;5D' backward-word
bindkey '\e[1;5C' forward-word
bindkey '\e[1;3D' backward-word
bindkey '\e[1;3C' forward-word

# Cmd+Left/Right arrive as Home/End (both cursor-key modes).
bindkey '\e[H' beginning-of-line
bindkey '\e[F' end-of-line
bindkey '\eOH' beginning-of-line
bindkey '\eOF' end-of-line

# Option/Ctrl + Backspace deletes the previous word; Cmd+Backspace (Ctrl+U)
# kills the line with the default binding.
bindkey $'\e\x7f' backward-kill-word
bindkey '^H' backward-kill-word
