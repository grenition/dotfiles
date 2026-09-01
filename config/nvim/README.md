# Neovim

A small, modular Neovim configuration with no distribution and no general-purpose UI framework.

## Requirements

On macOS, run `./install-deps-osx.sh` from the repo root to install `neovim`,
`git`, `rg`, `fzf`, and `tmux` via Homebrew (see `deps.txt`). A C compiler is
also needed for Treesitter parsers (comes with Xcode Command Line Tools), along
with `tree-sitter-cli` 0.26.1 or newer.

Start Neovim once to let `lazy.nvim` install the declared plugins. Run `:Mason` to inspect language servers.

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

## Kubernetes manifests

Kubernetes YAML files in `k8s/`, `kubernetes/`, or `manifests/` (and files ending
in `.k8s.yaml` or `.kubernetes.yaml`) receive Kubernetes schema completion and
validation from `yaml-language-server`, including schemas for known CRDs.

Mason installs `yamlfmt` and `kube-linter`. Use `<Space>oc` to format a manifest;
after each save, `kube-linter` reports best-practice diagnostics for YAML documents
that contain both `apiVersion` and `kind`. The statusline marks matched manifests
as `K8S` and shows `E`/`W` diagnostic counts. Other YAML files retain their generic
icon. SchemaStore detects conventional `.gitlab-ci.yml` files. Repositories made
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
file. Links and symbols with an LSP definition are underlined on hover without
replacing their syntax colour.

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
is the Visual Studio Code-inspired `vscode` theme: it automatically selects
Light+ or Dark+ from Neovim's `background` setting. `terminal` is a regular
no-background theme in both selectors.

## Development

Run `./scripts/check.sh` after every config change. It checks Lua syntax and
formatting when the corresponding tools are available, then starts the real
configuration headlessly with isolated cache and state directories. Repository
maintenance rules for coding agents live in `AGENTS.md`.
