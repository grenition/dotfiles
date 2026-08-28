# Tmux configuration guidance

## Scope

- Treat `tmux.conf` as the main configuration and `popup-zsh/.zshrc` as popup-only shell setup.
- Do not modify sibling dotfile configurations unless the user explicitly asks for it.
- Preserve unrelated worktree changes.

## Keybinding policy

- Keep `C-b` as the primary tmux prefix and `C-и` as its Russian-layout equivalent.
- Use prefix bindings for general tmux commands.
- Use global `Option` (`M-`) bindings for frequent window navigation, window lifecycle actions, pane navigation, and the popup shell.
- For every layout-dependent binding, add both the English key and the Russian character on the same physical QWERTY key. Modifier-independent keys such as `Tab` need only one binding.
- Keep `escape-time` at 20 ms or higher. A zero timeout can split the Escape prefix from multibyte Meta keys such as `M-х`.

## Direct shortcuts

| Action | English layout | Russian layout |
| --- | --- | --- |
| Next window | `M-Tab` | `M-Tab` |
| Previous window | `M-BTab` | `M-BTab` |
| New window | `M-t` | `M-е` |
| Close window | `M-w` | `M-ц` |
| Popup shell | `M-p` | `M-з` |
| Enter copy mode | `M-v` | `M-м` |
| Select pane left/down/up/right | `M-h/j/k/l` | `M-р/о/л/д` |

## Window closing

- `M-w` must close an idle shell window immediately.
- Before closing, inspect every pane with `scripts/window-has-active-process.zsh`.
- If any pane is running a foreground command other than the configured default shell, or if its shell has child/background processes, require confirmation before `kill-window`.
- Confirmation requires entering `y` or `н` and then pressing Enter. `n`, `т`, an empty response, or any other input cancels closing.
- Do not retain closed windows or their processes in hidden sessions.
- Do not bind `M-W`; closing a window is intentionally not reversible.
- Do not show informational status messages or popups. The destructive-action confirmation prompt is the only allowed feedback.

## Popup behavior

- Open the popup in `#{pane_current_path}` at 80% width and height.
- Keep popup-specific zsh behavior in `popup-zsh/.zshrc`; do not bind `Escape` globally.
- A lone `Escape` must close only the popup shell. Preserve normal Escape behavior everywhere else.
- Store popup shell history in `$HOME/.zsh_history`, never inside this repository.

## Verification

- Run `git diff --check` after edits.
- Load `tmux.conf` in an isolated tmux server and inspect every new binding with `list-keys`.
- Test closing both an idle shell window and a window with an active foreground process. The former must close immediately; the latter must remain open after `y` alone and close only after Enter.
- Test popup input behavior through an attached test client when changing `popup-zsh/.zshrc`.
- Reload the user's live tmux server only after isolated validation succeeds.
