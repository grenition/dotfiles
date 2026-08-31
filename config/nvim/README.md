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
icon, while `.gitlab-ci.yml`, `.gitlab/ci/`, and `gitlab/ci/` templates receive
explicit GitLab CI schema completion and validation. The main `.gitlab-ci.yml`
also uses the GitLab icon. In neo-tree, `+` means an untracked file (rather than
an error).

`gitlab-ci-ls` runs alongside `yaml-language-server` on those files and adds
GitLab-aware navigation, references, completion, hover, diagnostics, and job
renaming. On macOS, `install-deps-osx.sh` installs its Homebrew package. Template
repositories whose entry points do not use the conventional `.gitlab-ci.yml`
name need a `.gitlab-ci-ls.yml` file listing their `root_files`.

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

Terminals, the compact statusline, and buffer switching use built-in Neovim features.

Use `<Space>ud` and `<Space>un` to select persisted light and dark themes.
Neovim applies the matching macOS appearance on startup and focus. `terminal`
is a regular no-background theme in both selectors.

## Development

Run `./scripts/check.sh` after every config change. It checks Lua syntax and
formatting when the corresponding tools are available, then starts the real
configuration headlessly with isolated cache and state directories. Repository
maintenance rules for coding agents live in `AGENTS.md`.
