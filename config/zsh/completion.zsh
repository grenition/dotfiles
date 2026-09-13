# IDE-style command completion: Tab opens an fzf popup with a vertical,
# scrollable, height-capped list of choices (fzf-tab), history ghost text
# (zsh-autosuggestions), dynamic completions with live data like make targets
# and docker containers (carapace), command coloring (zsh-syntax-highlighting).
# Packages come from deps.txt; sourced from ~/.zshrc by the repo install script.

brew_prefix="${HOMEBREW_PREFIX:-/opt/homebrew}"

# Must be in fpath before the completion system initializes.
[ -d "$brew_prefix/share/zsh-completions" ] && fpath=("$brew_prefix/share/zsh-completions" $fpath)

# fzf-tab replaces the completion menu: one item per line, the window is capped
# by --height so long lists scroll inside it instead of flooding the screen,
# and nothing is ever accepted by a stray arrow — the menu opens only on Tab
# and accepts on Enter/Tab/Esc. Must be sourced after compinit, before the
# widget-wrapping plugins below.
autoload -Uz compinit && compinit
[ -f "$brew_prefix/share/fzf-tab/fzf-tab.zsh" ] && \
  source "$brew_prefix/share/fzf-tab/fzf-tab.zsh"
zstyle ':fzf-tab:*' fzf-flags --height=40% --layout=reverse --border

# The default query seeding ("input") puts the whole typed path into the fzf
# search (e.g. "ls /some/dir/<Tab>" searches for "/some/dir/") while carapace
# candidates are bare names, so the picker opens empty. Seed with the common
# prefix of the candidates instead: still pre-filters usefully ("al" -> the
# list starts filtered to "alpha*"), but never filters everything out.
zstyle ':fzf-tab:*' query-string prefix

# fzf-tab silently inserts an unambiguous common prefix without opening the
# picker (no upstream option for this yet, see Aloxaf/fzf-tab#596). Wrapping
# _complete and marking the list as forced disables that early exit, so the
# picker opens even when candidates share a prefix. A single match still
# completes instantly, without a window.
_force_menu() {
  local ret
  _complete "$@"
  ret=$?
  [[ $compstate[insert] == *unambiguous* ]] && compstate[list]=force
  return $ret
}
zstyle ':completion:*' completer _force_menu

# Fallback selection menu for when fzf-tab is not installed.
zstyle ':completion:*' menu select

# Gray ghost text: default fg=8 depends on the terminal palette mapping
# bright black to the foreground color; a truecolor hex gray is stable.
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#7f7f7f'

[ -f "$brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \
  source "$brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

command -v carapace >/dev/null 2>&1 && source <(carapace _carapace zsh)

# GLOB_DOTS makes file completion list hidden files without typing a leading
# dot, IDE-style (it also makes glob patterns like * match dotfiles). Carapace
# ignores it for file arguments, so plain file utilities are handed back to
# zsh's own completers; carapace keeps the dynamic commands (git, docker, ...).
setopt GLOB_DOTS
compdef _ls ls
compdef _files cat cp mv rm ln touch tail head less more

# Leave URL styling to the terminal; syntax highlighting should use color only.
typeset -gA ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=green'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=green'
ZSH_HIGHLIGHT_STYLES[autodirectory]='fg=green'

# Must be last: it wraps the widgets of the plugins above.
[ -f "$brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && \
  source "$brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
