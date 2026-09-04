# IDE-style command completion, layered on top of zsh's native system:
#
#   - zsh-autocomplete: live, as-you-type completion listing (IDE-style
#     IntelliSense); also initializes the completion system itself
#   - zsh-completions: extra completion definitions for many commands
#   - zsh-autosuggestions: fish-style ghost text from history (accept with
#     Right arrow or End, one word with Ctrl+Right)
#   - carapace: dynamic completions with descriptions for 1000+ commands,
#     including live data (make targets, docker containers, kubectl pods)
#
# Requires the Homebrew packages from install-deps-osx.sh. Sourced from
# ~/.zshrc by the repo install script.

if [ -n "${HOMEBREW_PREFIX:-}" ]; then
  brew_prefix="$HOMEBREW_PREFIX"
elif command -v brew >/dev/null 2>&1; then
  brew_prefix="$(brew --prefix)"
else
  brew_prefix="/opt/homebrew"
fi

# Extra completion definitions must be in fpath before the completion system
# initializes (zsh-autocomplete runs compinit itself).
[ -d "$brew_prefix/share/zsh-completions" ] && fpath=("$brew_prefix/share/zsh-completions" $fpath)

# Live completion listing while typing. Must be sourced before any compdef
# calls; it owns compinit, so do not call compinit elsewhere.
[ -f "$brew_prefix/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh" ] && \
  source "$brew_prefix/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh"

# Arrow-navigable completion menu on Tab / Down.
zstyle ':completion:*' menu select

# Fish-like ghost text suggestions from history. Load after zsh-autocomplete
# so that it can wrap its widgets.
[ -f "$brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \
  source "$brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Dynamic completions with descriptions (make targets, docker, kubectl, ...).
command -v carapace >/dev/null 2>&1 && source <(carapace _carapace zsh)
