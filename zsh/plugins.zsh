# Plugins and tools

# Yazi file manager
function y() {
	local tmp cwd; tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd" || builtin true
	command rm -f -- "$tmp"
}

if (( $+commands[mise] )); then
	# eval "$(mise activate zsh)"
fi

source <(fzf --zsh)

ZSH_PLUGIN_DIR=/usr/share
(( $+commands[brew] )) && ZSH_PLUGIN_DIR="${HOMEBREW_PREFIX:-$(brew --prefix)}/share"
if [[ -r "$ZSH_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
	source "$ZSH_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi
if [[ -r "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
	source "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
