return {
  "saghen/blink.cmp",
  event = "InsertEnter",
  version = "1.*",
  opts = {
    keymap = {
      preset = "default",
      ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
    },
    appearance = { nerd_font_variant = "mono" },
    completion = { documentation = { auto_show = false } },
    signature = { enabled = true },
    sources = { default = { "lsp", "path", "snippets", "buffer" } },
  },
}
