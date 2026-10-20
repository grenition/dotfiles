-- Ported from vim/vimrc

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 },             -- set global limits for large files for disabling features like treesitter
      autopairs = true,                                             -- enable autopairs at start
      cmp = true,                                                   -- enable completion at start
      diagnostics = { virtual_text = true, virtual_lines = false }, -- diagnostic settings on startup
      highlighturl = true,                                          -- highlight URLs at start
      notifications = true,                                         -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- passed to `vim.filetype.add`
    filetypes = {
      -- see `:h vim.filetype.add` for usage
      filename = {
        [".gitlab-ci.yml"] = "yaml.gitlab",
      },
      pattern = {
        [".*%.gitlab%-ci%.ya?ml"] = "yaml.gitlab",
        [".*/%.gitlab/ci/.*%.ya?ml"] = "yaml.gitlab",
        [".*/%.gitlab/workflows/.*%.ya?ml"] = "yaml.gitlab",
      },
    },
    -- vim options can be configured here
    options = {
      opt = {                  -- vim.opt.<key>
        relativenumber = true, -- sets vim.opt.relativenumber
        number = true,         -- sets vim.opt.number
        spell = false,         -- sets vim.opt.spell
        signcolumn = "yes",    -- sets vim.opt.signcolumn to yes
        wrap = false,          -- sets vim.opt.wrap
        scrolloff = 8,
        tabstop = 4,
        shiftwidth = 4,
        softtabstop = 4,
        expandtab = true,
        ignorecase = true,
        smartcase = true,
        incsearch = true,
        mouse = "a",
        splitbelow = true,
        splitright = true,
        clipboard = "unnamedplus",
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
      },
    },
    -- per-filetype indentation (from vimrc augroup)
    autocmds = {
      indent = {
        {
          event = "FileType",
          pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact", "json", "jsonc", "html", "css", "scss", "sass", "less", "xml", "yaml", "ruby", "sh", "zsh", "terraform", "hcl", "nix", "markdown" },
          command = "setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2",
        },
        {
          event = "FileType",
          pattern = { "python", "c", "cpp", "objc", "objcpp", "java", "kotlin", "cs", "rust", "php", "swift", "lua", "perl", "sql" },
          command = "setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4",
        },
        {
          event = "FileType",
          pattern = "go",
          command = "setlocal noexpandtab tabstop=8 shiftwidth=4 softtabstop=0",
        },
        {
          event = "FileType",
          pattern = "make",
          command = "setlocal noexpandtab tabstop=8 shiftwidth=8 softtabstop=0",
        },
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        -- second key is the lefthand side of the map

        -- navigate buffer tabs
        ["<Tab>"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["<S-Tab>"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

        -- mappings seen under group name "Buffer"
        ["<Leader>bd"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Close buffer from tabline",
        },

        ["<Leader><Leader>"] = { function() require("snacks").picker.recent() end, desc = "Recent files" },

        ["gp"] = {
          function() require("neo-tree.command").execute { action = "focus", reveal = true } end,
          desc = "Reveal in file tree",
        },

        -- tables with just a `desc` key will be registered with which-key if it's installed
        -- this is useful for naming menus
        -- ["<Leader>b"] = { desc = "Buffers" },

        -- setting a mapping to false will disable it
        -- ["<C-S>"] = false,

        -- from vimrc
        ["<Space>"] = "<Nop>",
        ["U"] = "<C-r>",
        ["<C-h>"] = "<C-w>h",
        ["<C-j>"] = "<C-w>j",
        ["<C-k>"] = "<C-w>k",
        ["<C-l>"] = "<C-w>l",
        ["<C-=>"] = "<C-w>=",
        ["<C-+>"] = "<C-w>+",
        ["<C-->"] = "<C-w>-",
        ["<C->>"] = "<C-w>>",
        ["<C-<>"] = "<C-w><",
        ["H"] = "20h",
        ["J"] = "10j",
        ["K"] = "10k",
        ["L"] = "20l",
        [">"] = ">>",
        ["<"] = "<<",
        ["dH"] = "20dh",
        ["dJ"] = "10dj",
        ["dK"] = "10dk",
        ["dL"] = "20dl",
        ["d"] = '"_d',
        ["D"] = '"_D',
        ["x"] = '"_x',
        ["X"] = '"_X',
        ["c"] = '"_c',
        ["C"] = '"_C',
        ["<BS>"] = { "<C-o>", desc = "Jump back" },
        ["<S-BS>"] = { "<C-i>", desc = "Jump forward" },

        -- macOS-style movement
        ["<C-Up>"] = "gg",
        ["<C-Down>"] = "G",
        ["<M-Left>"] = "b",
        ["<M-Right>"] = "w",
        ["<C-Left>"] = "b",
        ["<C-Right>"] = "w",
      },
      x = {
        ["<Tab>"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["<S-Tab>"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

        -- from vimrc
        ["<LeftRelease>"] = "y",
        ["H"] = "20h",
        ["J"] = "10j",
        ["K"] = "10k",
        ["L"] = "20l",
        ["<"] = "<gv",
        [">"] = ">gv",
        ["d"] = '"_d',
        ["D"] = '"_D',
        ["c"] = '"_c',
        ["C"] = '"_C',
        ["p"] = '"_dP',
        ["P"] = '"_dP',

        -- macOS-style movement
        ["<M-Left>"] = "b",
        ["<M-Right>"] = "w",
        ["<C-Left>"] = "b",
        ["<C-Right>"] = "w",
      },
      i = {
        -- macOS-style editing
        ["<M-BS>"] = { "<C-w>", desc = "Delete previous word" },
        ["<C-BS>"] = { "<C-w>", desc = "Delete previous word" },
        ["<C-h>"] = { "<C-w>", desc = "Delete previous word" },
        ["<M-Left>"] = { "<C-Left>", desc = "Previous word" },
        ["<M-b>"] = { "<C-Left>", desc = "Previous word" },
        ["<M-Right>"] = { "<C-Right>", desc = "Next word" },
        ["<M-f>"] = { "<C-Right>", desc = "Next word" },
        ["<M-Up>"] = { "<C-o>gk", desc = "Display line up" },
        ["<M-Down>"] = { "<C-o>gj", desc = "Display line down" },
        ["<C-Up>"] = { "<C-o>gg", desc = "First line" },
        ["<C-Down>"] = { "<C-o>G", desc = "Last line" },
      },
    },
  },
}
