local map = vim.keymap.set
local tools = require("config.tool_windows")

tools.setup()

local function project_root()
  return vim.fs.root(0, { ".git", "Makefile", "package.json" }) or vim.fn.getcwd()
end

local function terminal()
  for _, window in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buffer = vim.api.nvim_win_get_buf(window)
    if vim.bo[buffer].buftype == "terminal" then
      vim.api.nvim_set_current_win(window)
      vim.cmd("startinsert")
      return
    end
  end
  vim.cmd("botright 15split")
  vim.cmd("lcd " .. vim.fn.fnameescape(project_root()))
  vim.cmd("terminal")
  vim.cmd("startinsert")
end

local function organize_imports()
  vim.lsp.buf.code_action({
    apply = true,
    context = { only = { "source.organizeImports" } },
  })
end

local function close_unpinned_buffers()
  require("bufferline").groups.action("ungrouped", function(buffer)
    pcall(vim.api.nvim_buf_delete, buffer.id, {})
  end)
end

-- Windows and buffers
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })
map("n", "<C-o>", "<C-w>p", { desc = "Previous window" })
map("n", "<leader>v", "<C-w>v", { desc = "Vertical split" })
map("n", "<leader>h", "<C-w>s", { desc = "Horizontal split" })
map("n", "<S-CR>", "<C-w>v", { desc = "Open right split" })
map("n", "<C-=>", "<C-w>=", { desc = "Equalize windows" })
map("n", "<C-+>", "<C-w>+", { desc = "Increase window height" })
map("n", "<C-->", "<C-w>-", { desc = "Decrease window height" })
map("n", "<C->>", "<C-w>>", { desc = "Increase window width" })
map("n", "<C-<>", "<C-w><", { desc = "Decrease window width" })
map("n", "<Tab>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next visible buffer" })
map("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Previous visible buffer" })
map("x", "<Tab>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next visible buffer" })
map("x", "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Previous visible buffer" })
map("n", "<leader>x", require("config.buffers").close, { desc = "Close buffer" })
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Save" })
map("n", "<leader>bb", "<cmd>BufferLinePick<cr>", { desc = "Pick buffer" })
map("n", "<leader>b<", "<cmd>BufferLineMovePrev<cr>", { desc = "Move buffer left" })
map("n", "<leader>b>", "<cmd>BufferLineMoveNext<cr>", { desc = "Move buffer right" })
map("n", "<leader>bp", "<cmd>BufferLineTogglePin<cr>", { desc = "Pin buffer" })
map("n", "<leader>bq", "<cmd>BufferLineCloseOthers<cr>", { desc = "Close other buffers" })
map("n", "<leader>ba", close_unpinned_buffers, { desc = "Close unpinned buffers" })

-- Project tools
map("n", "<leader>e", tools.focus_or_open_explorer, { desc = "Project explorer" })
map("n", "<C-e>", tools.focus_or_open_explorer, { desc = "Project explorer" })
map("n", "gp", "<cmd>Neotree reveal<cr>", { desc = "Reveal in explorer" })
map("n", "<leader>t", terminal, { desc = "Terminal" })
map("n", "<C-t>", terminal, { desc = "Terminal" })
map("n", "<leader>gg", function() require("fzf-lua").git_status({ cwd = project_root() }) end, { desc = "Git changes" })

-- Search
map("n", "<leader>ff", function() require("fzf-lua").files({ cwd = project_root() }) end, { desc = "Files" })
map("n", "<C-p>", function() require("fzf-lua").files({ cwd = project_root() }) end, { desc = "Files" })
map("n", "<leader>fg", function() require("fzf-lua").live_grep({ cwd = project_root() }) end, { desc = "Grep" })
map("n", "<leader>fc", function() require("fzf-lua").live_grep({ cwd = project_root() }) end, { desc = "Grep" })
map("n", "<leader>fr", function() require("fzf-lua").oldfiles() end, { desc = "Recent files" })
map("n", "<leader><leader>", function() require("fzf-lua").oldfiles() end, { desc = "Recent files" })
map("n", "<leader>fd", function() require("fzf-lua").diagnostics_document() end, { desc = "Document diagnostics" })
map("n", "<leader>ft", function()
  require("fzf-lua").grep({ cwd = project_root(), search = "TODO|FIXME|HACK" })
end, { desc = "TODOs" })
map("n", "<leader>nt", function() require("fzf-lua").commands() end, { desc = "Commands" })
map("n", "<leader>0", function() require("fzf-lua").lsp_document_symbols() end, { desc = "File structure" })
map("n", "<M-j>", function() require("fzf-lua").lsp_document_symbols() end, { desc = "File structure" })
map("n", "<M-k>", function() require("fzf-lua").lsp_document_symbols() end, { desc = "File structure" })
map("n", "<leader>ud", function() require("config.theme").pick("light") end, { desc = "Choose light UI theme" })
map("n", "<leader>un", function() require("config.theme").pick("dark") end, { desc = "Choose dark UI theme" })
map("n", "<leader>uh", function() require("config.lsp_ui").pick("inlay_hints") end, { desc = "Configure inlay hints" })
map("n", "<leader>ul", function() require("config.lsp_ui").pick("code_lens") end, { desc = "Configure CodeLens references" })

-- LSP
map("n", "gd", require("config.navigation").goto_definition, { desc = "Definition, file, or URL" })
map("n", "gr", function() require("fzf-lua").lsp_references() end, { desc = "References" })
map("n", "gD", function() require("fzf-lua").lsp_typedefs() end, { desc = "Type definition" })
map("n", "gi", function() require("fzf-lua").lsp_implementations() end, { desc = "Implementations" })
map("n", "gu", function() require("fzf-lua").lsp_references() end, { desc = "Usages" })
map("n", "<BS>", "<C-o>", { desc = "Jump back" })
map("n", "<S-BS>", "<C-i>", { desc = "Jump forward" })
map("n", "<leader>rr", vim.lsp.buf.rename, { desc = "Rename symbol" })
map("n", "<leader>k", vim.lsp.buf.hover, { desc = "Documentation" })
map("n", "<leader>i", function() require("fzf-lua").lsp_implementations() end, { desc = "Implementations" })
map("n", "<leader>ur", function() require("fzf-lua").lsp_references() end, { desc = "Usages" })
map({ "n", "i" }, "<C-s>", vim.lsp.buf.signature_help, { desc = "Signature help" })
map({ "n", "x" }, "<leader>a", vim.lsp.buf.code_action, { desc = "Code actions" })
map({ "n", "x" }, "<leader>oe", vim.lsp.buf.code_action, { desc = "Code actions" })
map("n", "<leader>ol", vim.lsp.codelens.run, { desc = "Run code lens" })
map("n", "<leader>oc", function() require("conform").format({ lsp_format = "fallback" }) end, { desc = "Format" })
map("n", "<leader>oi", organize_imports, { desc = "Organize imports" })
map("n", "<leader>oa", function()
  require("conform").format({ lsp_format = "fallback" })
  organize_imports()
end, { desc = "Format and organize imports" })

-- Personal editing preferences
map("n", "U", "<C-r>")
for _, mode in ipairs({ "n", "x" }) do
  map(mode, "H", "20h")
  map(mode, "J", "10j")
  map(mode, "K", "10k")
  map(mode, "L", "20l")
end
map("x", "<", "<gv")
map("x", ">", ">gv")
map({ "n", "x" }, "d", '"_d')
map({ "n", "x" }, "D", '"_D')
map("n", "x", '"_x')
map("n", "X", '"_X')
map({ "n", "x" }, "c", '"_c')
map({ "n", "x" }, "C", '"_C')
map("x", "p", '"_dP')
map("x", "P", '"_dP')

-- macOS terminals send Option+Backspace as Meta+Backspace when configured to
-- use Esc+.  Keep it a normal word deletion inside Insert mode.
map("i", "<M-BS>", "<C-w>", { desc = "Delete previous word" })
