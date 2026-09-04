# IDE-style command completion: live as-you-type menu (zsh-autocomplete),
# history ghost text (zsh-autosuggestions), dynamic completions with live
# data like make targets and docker containers (carapace), command coloring
# (zsh-syntax-highlighting). Packages come from deps.txt; sourced from
# ~/.zshrc by the repo install script.

brew_prefix="${HOMEBREW_PREFIX:-/opt/homebrew}"

# Must be in fpath before the completion system initializes.
[ -d "$brew_prefix/share/zsh-completions" ] && fpath=("$brew_prefix/share/zsh-completions" $fpath)

# zsh-autocomplete owns compinit and must be sourced before any compdef.
[ -f "$brew_prefix/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh" ] && \
  source "$brew_prefix/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh"

zstyle ':completion:*' menu select

[ -f "$brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \
  source "$brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

command -v carapace >/dev/null 2>&1 && source <(carapace _carapace zsh)

# Must be last: it wraps the widgets of the plugins above.
[ -f "$brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && \
  source "$brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
