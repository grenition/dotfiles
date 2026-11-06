# Prompt/theme
if (( $+commands[starship] )); then
	export STARSHIP_CONFIG="$ZSH_CONFIG_HOME/starship.toml"
	eval "$(starship init zsh)"
fi
