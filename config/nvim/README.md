# Neovim

A small, modular Neovim configuration with no distribution and no general-purpose UI framework.

## Requirements

- Neovim 0.11+
- `git`, `rg`, and `fzf`
- A compiler for Treesitter parsers

Start Neovim once to let `lazy.nvim` install the declared plugins. Run `:Mason` to inspect language servers.

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
| `bufferline.nvim` | Open-buffer tabs |
| `which-key.nvim` | Keybinding hints |

Terminals, the compact statusline, and buffer switching use built-in Neovim features.

Use `<Space>ud` and `<Space>un` to select persisted light and dark themes.
Neovim applies the matching macOS appearance on startup and focus. `terminal`
is a regular no-background theme in both selectors.
