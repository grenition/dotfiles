# Neovim

A small, modular Neovim configuration with no distribution and no general-purpose UI framework.

## Requirements

On macOS, run `./install-deps-osx.sh` from the repo root to install `neovim`,
`git`, `rg`, `fzf`, `tmux`, and the Go tools `gopls` and `goimports` via
Homebrew (see `deps.txt`). A C compiler is
also needed for Treesitter parsers (comes with Xcode Command Line Tools), along
with `tree-sitter-cli` 0.26.1 or newer.

Start Neovim once to let `lazy.nvim` install the declared plugins. Pressing
`<Space>` opens a which-key menu that groups and describes every leader
mapping (Search, Buffers, Code, UI, Git). A single managed-tool
registry then installs the configured language servers, linters, and formatters through
Mason. Run `:ToolingInfo` to see their readiness, `:MasonToolsInstall` to retry missing
tools, and `:MasonLog` for installation details. Failed or incomplete install passes
produce one aggregated warning; newly installed language servers become available in
the same session.

## C#

The configuration installs the official `roslyn-language-server` for diagnostics,
completion, refactors, inlay hints, CodeLens reference counts, and metadata-as-source
decompilation, plus `csharpier` for formatting. The C# Treesitter parser is also
installed. Open a `.cs` file inside a directory containing a `.sln`, `.slnx`, or
`.csproj`; use `<Space>oc` to format, `<Space>oi` to organize imports,
`<Space>oa` for both, and `<Space>ol` to run the CodeLens at the cursor. C# tooling
is optional: when the .NET SDK is absent, it is not installed or started; standalone
`.cs` files retain syntax highlighting only.

Use `<Space>uh` to choose whether LSP inlay hints are shown and `<Space>ul` to do
the same for CodeLens reference counts. Both preferences are saved in the config and
apply to every language server that supports the corresponding feature.

## Go

`gopls` and `goimports` are installed by the platform dependency script
(Homebrew on macOS, see `deps.txt`) instead of Mason, alongside the Homebrew
Go toolchain. Opening a Go file starts `gopls` for diagnostics, completion,
navigation, refactors, and inlay hints. gopls's remaining code lenses (run
tests, go generate) are wired up: run the lens at the cursor with `<Space>ol`
and toggle lenses with `<Space>ul`. Since gopls v0.23 removed its references
code lens, `N refs` counts above functions, methods, and types are computed
from `gopls`'s references (`config/refcounts.lua`). Use `<Space>oc` to format with
`goimports` (falling back to the toolchain's `gofmt`) and `<Space>oi` to
organize imports. The statusline shows the current Go module as `go:<name>`.
The Go Treesitter parser is installed with the
configuration. Go tooling is optional: when the Go toolchain is absent,
nothing is installed or started; `.go` files retain syntax highlighting only.

## Python

`pyright` and `ruff` are installed through Mason. `pyright` automatically uses
the project's virtual environment — `.venv` or `venv` in the project root, or
Poetry's cached virtualenv — and falls back to the system Python when the
project has none. The statusline shows the active environment as `py:<name>`.
Opening a Python file starts
`pyright` for diagnostics, completion, navigation, refactors, and inlay hints,
while `ruff` adds its own diagnostics and import actions. Since `pyright`
has no code-lens provider, the configuration computes `N refs` counts from
`pyright`'s references and shows them above classes, functions, and methods
(`config/refcounts.lua`). Use `<Space>oc` to
format with `ruff` and `<Space>oi` to organize imports. The Python Treesitter
parser is installed with the configuration. Python tooling is optional: when
no Python 3 interpreter is available, nothing is installed or started; `.py`
files retain syntax highlighting only.

## Clipboard and macOS editing keys

Ctrl and Option plus arrows move by word, Cmd plus Left/Right arrive as
Home/End and Cmd+Backspace as Ctrl+U (line deletion), Cmd+Up/Down jump to
the first and last line, and Ctrl/Option+Backspace deletes the previous
word — in Insert mode and in the shell (`config/zsh/keybindings.zsh`),
matching native macOS text fields. Insert mode maps every common
modifier+arrow combination so no key ever splits into a bare Esc that
would switch back to Normal mode. Shift+arrows (and their Ctrl/Option/Cmd
combos) start a native Select-mode selection via `keymodel=startsel`:
typing or Backspace replaces it, and `<C-c>` copies it to the system
clipboard. `<C-c>` also yanks a Visual-mode selection, `<C-x>` cuts it, and
`<C-v>` pastes the system clipboard in Insert mode (Normal-mode `<C-v>`
stays visual block). Releasing the mouse after a drag selection (or
double-clicking a word) yanks it to the system clipboard immediately and
drops the Visual highlight, matching the tmux mouse-copy behavior. Inside
neo-tree the Shift+arrows navigate the tree
instead of selecting text.

## Undo, redo, and hover

`u`/`U` undo and redo the edit in every file touched by the last LSP
rename or code action, not just the current buffer. Only text edits
propagate: file creation, renaming, and deletion from workspace edits are
not undoable. In the file tree `u`/`U` do nothing — file operations there
are not undoable, and neo-tree's trash is the recovery path. The
`<Space>k` documentation/diagnostic float closes with `Esc` or `q` in
addition to moving the cursor away. The float renders highlighted Markdown
(fenced code blocks use the source language's highlighting via Treesitter
injections) and grows up to 60% of the screen instead of truncating.

## Kubernetes manifests

Kubernetes YAML files in `k8s/`, `kubernetes/`, or `manifests/` (and files ending
in `.k8s.yaml` or `.kubernetes.yaml`) receive Kubernetes schema completion and
validation from `yaml-language-server`, including schemas for known CRDs. In
sops+Kustomize repositories (root `.sops.yaml` marker), the broad globs are
replaced by an allow-list: only the named workload manifests under `k8s/apps/*/`
and everything under `k8s/infrastructure/` keep the Kubernetes schema, and
`kustomization.yaml` validates against the Kustomization schema, so
sops-encrypted secrets, Helm values, and plain app configs are not validated
as workloads.

The managed-tool registry installs `yamlfmt` and `kube-linter`. Use `<Space>oc`
to format a manifest; after each save, `kube-linter` reports best-practice
diagnostics for YAML documents
that contain both `apiVersion` and `kind`. If the linter is still installing or its
installation failed, saving reports its state and the retry command instead of raising
an executable error. The statusline marks matched manifests
as `K8S` and shows `E`/`W` diagnostic counts. Other YAML files keep their generic
icon, except sops-encrypted secrets (`*.sops.yaml`), `kustomization.yaml`,
named workload manifests under `k8s/`, and Helm files (`values.yaml`,
`*-values.yaml`, `Chart.yaml`), which show dedicated icons in neo-tree.
SchemaStore detects conventional `.gitlab-ci.yml` files. Repositories made
entirely of arbitrarily named GitLab templates can opt in with one
`.gitlab-ci-ls.yml` project marker instead of maintaining filename patterns. In
neo-tree, `+` means an untracked file (rather than an error).

`gitlab-ci-ls` runs alongside `yaml-language-server` on those files and adds
GitLab-aware navigation, references, completion, hover, diagnostics, and job
renaming. On macOS, `install-deps-osx.sh` installs its Homebrew package. The same
`.gitlab-ci-ls.yml` marker lists the entry points of template repositories.
Files covered by that marker use the GitLab icon in neo-tree and the bufferline.

`gd` first opens an HTTP(S) URL or an existing local path under the cursor. Local
paths are resolved relative to the current file and then the project root; a
leading `/` also supports GitLab's project-root-relative include convention. If
there is no file or URL under the cursor, `gd` falls back to LSP definition.
Navigable URLs and paths are underlined while the cursor is on them.
If a remote URL points back into the current repository, `gd` opens its local
file.

Markdown uses Marksman for heading symbols, completion, hover, diagnostics,
references, rename, and `gd` navigation through file links and heading anchors.

The current `gitlab-ci-ls` release is useful for jobs, `extends`, `needs`, and
stages, but it is not feature-equivalent to the JetBrains GitLab integration. In
particular, variable navigation inside `rules:if` and GitLab's built-in
`include:template` form are not implemented upstream yet.

## Plugins

| Plugin | Responsibility |
| --- | --- |
| `neo-tree.nvim` | Project tree and file operations (`h/j/k/l`, `x`, `y`, `p`) |
| `fzf-lua` | Files, grep, commands, diagnostics, and LSP lists |
| `nvim-lspconfig` + Mason | Language servers |
| `blink.cmp` | Completion |
| `nvim-treesitter` | Syntax-aware highlighting and indenting |
| `indent-blankline.nvim` | Indent guides and the current code scope |
| `rainbow-delimiters.nvim` | Nested brackets and blocks in terminal colours |
| `nvim-treesitter-textobjects` | Select functions, classes, and blocks (`af`, `if`, `ac`, `ic`, `ab`, `ib`) |
| `gitsigns.nvim` | Git changes in the sign column |
| `conform.nvim` | Formatting |
| `nvim-lint` | Kubernetes manifest linting via `kube-linter` |
| `bufferline.nvim` | Open-buffer tabs |
| `which-key.nvim` | Keybinding hints |
| `vscode.nvim` | Visual Studio Code Light+ and Dark+ theme |
| `codewindow.nvim` | VS Code-style minimap, on by default (`<Space>um`) |

Terminals, the compact statusline, and buffer switching use built-in Neovim features.
The bufferline keeps close buttons visible on every buffer. Middle-click also
closes a buffer; `<Space>bb` labels buffers for quick selection, while
`<Space>b<` and `<Space>b>` reorder them. Unnamed scratch buffers are omitted,
and file icons inherit the tab background. `<Tab>` and `<Shift-Tab>` cycle
through this visible left-to-right order, skipping omitted buffers. Neovim's
tabline is a single terminal row, so a long buffer list scrolls with visible
overflow markers instead of wrapping.

Use `<Space>ud` and `<Space>un` to select persisted light and dark themes.
Neovim applies the matching macOS appearance on startup and focus. The default
is the Visual Studio Code-inspired theme. Its `vscode-light` (Light+) and
`vscode-dark` (Dark+) variants are separate entries in both selectors, so live
preview always shows the named variant. `terminal` is a regular no-background
theme in both selectors.

The minimap is on by default and follows the active window. `<Space>um` toggles
it for the current session. It auto-hides when the editor window is narrower
than 80 columns and returns when space does. It is skipped for help, neo-tree,
fzf, and quickfix windows.

## Development

Run `./scripts/check.sh` after every config change. It checks Lua syntax and
formatting when the corresponding tools are available, then starts the real
configuration headlessly with isolated cache and state directories. Repository
maintenance rules for coding agents live in `AGENTS.md`.
