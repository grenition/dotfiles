# IDE-style command completion: live as-you-type menu (zsh-autocomplete),
# history ghost text (zsh-autosuggestions), dynamic completions with live
# data like make targets and docker containers (carapace), command coloring
# (zsh-syntax-highlighting). Packages come from deps.txt; sourced from
# ~/.zshrc by the repo install script.

brew_prefix="${HOMEBREW_PREFIX:-/opt/homebrew}"

# Must be in fpath before the completion system initializes.
[ -d "$brew_prefix/share/zsh-completions" ] && fpath=("$brew_prefix/share/zsh-completions" $fpath)

# Keep history selections identical to the original command line.
zstyle ':autocomplete:*' add-semicolon no

# zsh-autocomplete owns compinit and must be sourced before any compdef.
[ -f "$brew_prefix/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh" ] && \
  source "$brew_prefix/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh"

# Submit immediately instead of using Enter to leave the completion menu.
bindkey -M menuselect '^M' .accept-line
# Accept the selected directory and continue completing with Tab.
bindkey -M menuselect '^I' accept-and-infer-next-history

# Its recent-dirs feature writes to this dir on every cd, but nothing creates it.
mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/zsh"

zstyle ':completion:*' menu select

# Gray ghost text: default fg=8 depends on the terminal palette mapping
# bright black to the foreground color; a truecolor hex gray is stable.
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#7f7f7f'

[ -f "$brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \
  source "$brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

command -v carapace >/dev/null 2>&1 && source <(carapace _carapace zsh)

# Leave URL styling to the terminal; syntax highlighting should use color only.
typeset -gA ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=green'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=green'
ZSH_HIGHLIGHT_STYLES[autodirectory]='fg=green'

# Must be last: it wraps the widgets of the plugins above.
[ -f "$brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && \
  source "$brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
