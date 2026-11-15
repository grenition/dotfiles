# Yazi file manager
function y() {
	local tmp cwd; tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd" || builtin true
	command rm -f -- "$tmp"
}

# Mise
if (( $+commands[mise] )); then
	# eval "$(mise activate zsh)"
fi

# Fzf
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:+$FZF_DEFAULT_OPTS }--color=16,bg:-1,bg+:-1,fg:-1,fg+:-1,hl:4,hl+:4,pointer:4,marker:2,info:8,spinner:4,header:8,border:8"
source <(fzf --zsh)

ZSH_PLUGIN_DIR=/usr/share
(( $+commands[brew] )) && ZSH_PLUGIN_DIR="${HOMEBREW_PREFIX:-$(brew --prefix)}/share"
if [[ -r "$ZSH_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
	source "$ZSH_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi
if [[ -r "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
	source "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"

# Direnv
eval "$(direnv hook zsh)"
