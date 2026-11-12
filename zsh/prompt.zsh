# Prompt/theme
if (( $+commands[starship] )); then
	export STARSHIP_CONFIG="$ZSH_CONFIG_HOME/starship.toml"
	eval "$(starship init zsh)"

	# Width-based break is not supported by starship (starship#7548):
	# zsh adds the break and the prompt symbol ([character] is disabled in starship.toml)
	typeset -g STARSHIP_PROMPT_BREAK_PCT=60
	typeset -g _starship_status_expr=$PROMPT

	_starship_prompt() {
		local rendered=${(e)_starship_status_expr}
		local visible=${(S)rendered//'%{'*'%}'/}
		local newline=''
		(( ${#visible} * 100 > ${COLUMNS:-80} * STARSHIP_PROMPT_BREAK_PCT )) && newline=$'\n'
		local symbol=$'\e[1;32m❯\e[0m'
		(( ${STARSHIP_CMD_STATUS:-0} )) && symbol=$'\e[1;31m❯\e[0m'
		[[ ${KEYMAP:-} == vicmd ]] && symbol=$'\e[1;33m❮\e[0m'
		print -r -- "$rendered$newline%{$symbol%} "
	}
	PROMPT='$(_starship_prompt)'
fi
