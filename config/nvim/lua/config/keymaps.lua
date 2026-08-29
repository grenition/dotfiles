local map = vim.keymap.set

require("config.tool_windows").setup()

local function explorer()
  local current = Snacks.picker.get({ source = "explorer" })[1]
  if current then
    current:focus()
    return current
  end
  return Snacks.explorer({ cwd = LazyVim.root() })
end

local function terminal()
  local current = Snacks.terminal.get(nil, { cwd = LazyVim.root() })
  current:show()
  current:focus()
  return current
end

local function todo()
  return require("trouble").open({ mode = "todo", open_no_results = true, warn_no_results = false })
end

local function symbols()
  Snacks.picker.lsp_symbols({ filter = LazyVim.config.kind_filter })
end

local function organize_imports()
  vim.lsp.buf.code_action({
    apply = true,
    context = { only = { "source.organizeImports" } },
  })
end

-- Window navigation
map("n", "<C-h>", "<C-w>h", { silent = true, desc = "Navigate Left" })
map("n", "<C-l>", "<C-w>l", { silent = true, desc = "Navigate Right" })
map("n", "<C-j>", "<C-w>j", { silent = true, desc = "Navigate Down" })
map("n", "<C-k>", "<C-w>k", { silent = true, desc = "Navigate Up" })
map("n", "<C-o>", "<C-w>p", { silent = true, desc = "Opposite Editor Group" })

-- Split windows
map("n", "<leader>v", "<C-w>v", { silent = true, desc = "Split Vertically" })
map("n", "<leader>h", "<C-w>s", { silent = true, desc = "Split Horizontally" })
map("n", "<S-CR>", "<C-w>v", { silent = true, desc = "Open in Right Split" })
map("n", "<D-\\>", "<C-w>v", { silent = true, desc = "Open in Right Split" })

map("n", "<C-=>", "<C-w>=", { silent = true, desc = "Equalize Windows" })
map("n", "<C-+>", "<C-w>+", { silent = true, desc = "Increase Window Height" })
map("n", "<C-->", "<C-w>-", { silent = true, desc = "Decrease Window Height" })
map("n", "<C->>", "<C-w>>", { silent = true, desc = "Increase Window Width" })
map("n", "<C-<>", "<C-w><", { silent = true, desc = "Decrease Window Width" })

-- Close and save
map("n", "<leader>x", function()
  Snacks.bufdelete()
end, { silent = true, desc = "Close Content" })
map("n", "<leader>w", "<cmd>w<cr>", { silent = true, desc = "Save Document" })

-- Buffer management
map("n", "<leader>bp", "<cmd>BufferLineTogglePin<cr>", { silent = true, desc = "Pin Active Editor Tab" })
map("n", "<leader>bq", "<cmd>BufferLineCloseOthers<cr>", { silent = true, desc = "Close All Editors But Active" })
map(
  "n",
  "<leader>ba",
  "<cmd>BufferLineGroupClose ungrouped<cr>",
  { silent = true, desc = "Close All Unpinned Editors" }
)

-- Rider / IdeaVim tool windows and search
map("n", "<leader>e", explorer, { desc = "Project Explorer" })
map("n", "<leader>t", terminal, { desc = "Terminal" })
map("n", "<C-e>", explorer, { desc = "Project Explorer" })
map("n", "<C-t>", terminal, { desc = "Terminal" })
map("n", "<leader>ff", LazyVim.pick("files"), { desc = "Go to File" })
map("n", "<leader>fc", LazyVim.pick("live_grep"), { desc = "Find in Path" })
map("n", "<leader>fd", function()
  Snacks.picker.diagnostics()
end, { desc = "Diagnostics" })
map("n", "<leader>fg", LazyVim.pick("live_grep"), { desc = "Find in Path" })
map("n", "<leader>ft", todo, { desc = "TODO" })
map("n", "<leader>fr", LazyVim.pick("oldfiles"), { desc = "Recent Files" })
map("n", "<leader><leader>", LazyVim.pick("oldfiles"), { desc = "Recent Files" })

-- Rider / IdeaVim navigation and LSP actions
map("n", "gd", function()
  Snacks.picker.lsp_definitions()
end, { desc = "Go to Declaration" })
map("n", "gr", function()
  Snacks.picker.lsp_references()
end, { desc = "Find Usages", nowait = true })
map("n", "gD", function()
  Snacks.picker.lsp_type_definitions()
end, { desc = "Go to Type Declaration" })
map("n", "gi", function()
  Snacks.picker.lsp_implementations()
end, { desc = "Go to Implementation" })
map("n", "gp", function()
  Snacks.explorer.reveal()
end, { desc = "Select in Project View" })
map("n", "gu", function()
  Snacks.picker.lsp_references()
end, { desc = "Show Usages" })
map("n", "<BS>", "<C-o>", { silent = true, desc = "Navigate Back" })
map("n", "<S-BS>", "<C-i>", { silent = true, desc = "Navigate Forward" })

map("n", "<leader>rr", vim.lsp.buf.rename, { desc = "Rename Element" })
map("n", "<leader>oc", function()
  LazyVim.format({ force = true })
end, { desc = "Reformat Code" })
map("n", "<leader>oi", organize_imports, { desc = "Optimize Imports" })
map("n", "<leader>oa", function()
  LazyVim.format({ force = true })
  organize_imports()
end, { desc = "Reformat and Optimize Imports" })
map({ "n", "x" }, "<leader>oe", vim.lsp.buf.code_action, { desc = "Edit Code Action" })
map({ "n", "x" }, "<leader>a", vim.lsp.buf.code_action, { desc = "Intention Actions" })
map({ "n", "x" }, "<M-CR>", vim.lsp.buf.code_action, { desc = "Quick Fix" })
map("n", "<leader>k", vim.lsp.buf.hover, { desc = "Quick Documentation" })
map("n", "<leader>i", function()
  Snacks.picker.lsp_implementations()
end, { desc = "Quick Implementations" })
map("n", "<leader>u", function()
  Snacks.picker.lsp_references()
end, { desc = "Show Usages" })
map({ "n", "i" }, "<C-s>", vim.lsp.buf.signature_help, { desc = "Parameter Info" })

-- Rider structure and action search
map("n", "<leader>0", symbols, { desc = "File Structure" })
map("n", "<M-j>", symbols, { desc = "File Structure" })
map("n", "<M-k>", symbols, { desc = "File Structure" })
map("n", "<leader>nH", function()
  Snacks.explorer.reveal()
end, { desc = "Show in Project Explorer" })
map("n", "<leader>nt", function()
  Snacks.picker.commands()
end, { desc = "Find Action" })

-- Active Rider macOS keymap aliases. Whether Command reaches Neovim depends on
-- the terminal, but these also work in GUIs that support the D modifier.
map("n", "<D-1>", explorer, { desc = "Project Explorer" })
map("n", "<D-2>", terminal, { desc = "Terminal" })
map("n", "<D-w>", function()
  Snacks.bufdelete()
end, { desc = "Close Content" })
map("n", "<D-->", "<C-o>", { silent = true, desc = "Navigate Back" })
map("n", "<C-p>", LazyVim.pick("files"), { desc = "Go to File" })
map("n", "<D-p>", LazyVim.pick("live_grep"), { desc = "Find in Path" })
map("n", "<D-S-p>", function()
  Snacks.picker.commands()
end, { desc = "Find Action" })
map("n", "<F12>", function()
  Snacks.picker.lsp_definitions()
end, { desc = "Go to Declaration" })
map("n", "<C-Tab>", "<cmd>BufferLineCycleNext<cr>", { silent = true, desc = "Next Editor" })
map("n", "<C-S-Tab>", "<cmd>BufferLineCyclePrev<cr>", { silent = true, desc = "Previous Editor" })
map("n", "<D-k><D-p>", "<cmd>BufferLineTogglePin<cr>", { silent = true, desc = "Pin Active Editor" })
map("n", "<D-k><D-u>", "<cmd>BufferLineTogglePin<cr>", { silent = true, desc = "Unpin Active Editor" })
map("n", "<D-k><D-a>", "<cmd>BufferLineCloseOthers<cr>", { silent = true, desc = "Close Other Editors" })
map("n", "<D-/>", "gcc", { remap = true, desc = "Toggle Line Comment" })
map("x", "<D-/>", "gc", { remap = true, desc = "Toggle Comment" })

-- vimrc

map("n", "U", "<C-r>", { noremap = true, silent = true })

map("n", "<M-h>", "20h", { noremap = true, silent = true })
map("n", "<M-l>", "20l", { noremap = true, silent = true })

map("n", "H", "20h", { noremap = true, silent = true })
map("n", "J", "10j", { noremap = true, silent = true })
map("n", "K", "10k", { noremap = true, silent = true })
map("n", "L", "20l", { noremap = true, silent = true })

map("x", "H", "20h", { noremap = true, silent = true })
map("x", "J", "10j", { noremap = true, silent = true })
map("x", "K", "10k", { noremap = true, silent = true })
map("x", "L", "20l", { noremap = true, silent = true })
map("x", "<", "<gv", { noremap = true, silent = true })
map("x", ">", ">gv", { noremap = true, silent = true })

map("n", "dH", "20dh", { noremap = true, silent = true })
map("n", "dJ", "10dj", { noremap = true, silent = true })
map("n", "dK", "10dk", { noremap = true, silent = true })
map("n", "dL", "20dl", { noremap = true, silent = true })

map({ "n", "v" }, "d", '"_d', { noremap = true, silent = true })
map({ "n", "v" }, "D", '"_D', { noremap = true, silent = true })
map("n", "x", '"_x', { noremap = true, silent = true })
map("n", "X", '"_X', { noremap = true, silent = true })
map({ "n", "v" }, "c", '"_c', { noremap = true, silent = true })
map({ "n", "v" }, "C", '"_C', { noremap = true, silent = true })
map("x", "p", '"_dP', { noremap = true, silent = true })
map("x", "P", '"_dP', { noremap = true, silent = true })

map({ "n", "v" }, "<Tab>", "<cmd>BufferLineCycleNext<cr>", { noremap = true, silent = true })
map({ "n", "v" }, "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", { noremap = true, silent = true })
