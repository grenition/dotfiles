local map = vim.keymap.set

-- Window navigation
map("n", "<C-h>", "<C-w>h", { silent = true, desc = "Navigate Left" })
map("n", "<C-l>", "<C-w>l", { silent = true, desc = "Navigate Right" })
map("n", "<C-j>", "<C-w>j", { silent = true, desc = "Navigate Down" })
map("n", "<C-k>", "<C-w>k", { silent = true, desc = "Navigate Up" })

map("n", "<D-h>", "<C-w>h", { silent = true, desc = "Navigate Left" })
map("n", "<D-l>", "<C-w>l", { silent = true, desc = "Navigate Right" })
map("n", "<D-j>", "<C-w>j", { silent = true, desc = "Navigate Down" })
map("n", "<D-k>", "<C-w>k", { silent = true, desc = "Navigate Up" })

-- Split windows
map("n", "<leader>v", "<C-w>v", { silent = true, desc = "Split Vertically" })
map("n", "<leader>h", "<C-w>s", { silent = true, desc = "Split Horizontally" })
map("n", "<D-o>", "<C-w>r", { silent = true, desc = "Move Editor to Opposite Tab Group" })

-- Close and save
map("n", "<leader>x", "<cmd>close<cr>", { silent = true, desc = "Close Content" })
map("n", "<leader>w", "<cmd>w<cr>", { silent = true, desc = "Save Document" })

-- Buffer management
map("n", "<leader>bp", "<cmd>BufferLineTogglePin<cr>", { silent = true, desc = "Pin Active Editor Tab" })
map("n", "<leader>bq", "<cmd>BufferLineCloseOther<cr>", { silent = true, desc = "Close All Editors But Active" })

-- Search
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { silent = true, desc = "Goto File" })
map("n", "<leader>fd", vim.diagnostic.open_float, { silent = true, desc = "Help Diagnostic Tools" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { silent = true, desc = "Find In Path" })
map("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { silent = true, desc = "Activate TODO Tool Window" })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { silent = true, desc = "Recent Files" })
map("n", "<leader><leader>", "<cmd>Telescope builtin<cr>", { silent = true, desc = "Search Everywhere" })

-- Test
map("n", "<leader>ot", "<cmd>Neotest jump<cr>", { silent = true, desc = "Goto Test" })
map("n", "<leader>T", "<cmd>Neotest run file<cr>", { silent = true, desc = "Run Class" })

-- Completion
map("i", "<C-Space>", "<C-x><C-o>", { desc = "Code Completion" })
map("i", "<C-@>", "<C-x><C-o>", { desc = "Code Completion" })

-- LSP Navigation
map("n", "gd", vim.lsp.buf.declaration, { silent = true, desc = "Go to Declaration" })
map("n", "gr", "<cmd>Telescope lsp_references<cr>", { silent = true, desc = "Find Usages" })
map("n", "gD", vim.lsp.buf.type_definition, { silent = true, desc = "Go to Type Definition" })
map("n", "gi", vim.lsp.buf.implementation, { silent = true, desc = "Go to Implementation" })
map("n", "<BS>", "<C-o>", { silent = true, desc = "Navigate Back" })

map("n", "<leader>rr", vim.lsp.buf.rename, { silent = true, desc = "Rename Element" })

-- Format and organize imports
map("n", "<leader>oc", function()
  vim.lsp.buf.format({ async = true })
end, { silent = true, desc = "Reformat Code" })

map("n", "<leader>oi", function()
  local params = vim.lsp.util.make_range_params()
  params.context = { only = { "source.organizeImports" } }
  local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 1000)
  if result and result[1] then
    for _, res in pairs(result) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          vim.lsp.util.apply_workspace_edit(r.edit, "utf-8")
        else
          vim.lsp.buf.execute_command(r.command)
        end
      end
    end
  end
end, { silent = true, desc = "Optimize Imports" })

map("n", "<leader>oa", function()
  -- First format
  vim.lsp.buf.format({ async = false })
  -- Then organize imports
  local params = vim.lsp.util.make_range_params()
  params.context = { only = { "source.organizeImports" } }
  local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 1000)
  if result and result[1] then
    for _, res in pairs(result) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          vim.lsp.util.apply_workspace_edit(r.edit, "utf-8")
        else
          vim.lsp.buf.execute_command(r.command)
        end
      end
    end
  end
end, { silent = true, desc = "Reformat Code + Optimize Imports" })

map("n", "<leader>k", vim.lsp.buf.hover, { silent = true, desc = "Quick JavaDoc / Hover" })
map("n", "<leader>i", vim.lsp.buf.implementation, { silent = true, desc = "Quick Implementations" })
map("n", "<leader>u", "<cmd>Telescope lsp_references<cr>", { silent = true, desc = "Show Usages" })

map("i", "<C-s>", function()
  vim.lsp.buf.signature_help()
end, { silent = true, desc = "Parameter Info" })
map("n", "<C-s>", function()
  vim.lsp.buf.signature_help()
end, { silent = true, desc = "Parameter Info" })

map("n", "<leader>a", vim.lsp.buf.code_action, { silent = true, desc = "Show Intention Actions" })

map("n", "<leader>0", "<cmd>Telescope lsp_document_symbols<cr>", { silent = true, desc = "File Structure Popup" })

map({ "n", "x", "o" }, "й", "q")
map({ "n", "x", "o" }, "ц", "w")
map({ "n", "x", "o" }, "у", "e")
map({ "n", "x", "o" }, "к", "r")
map({ "n", "x", "o" }, "е", "t")
map({ "n", "x", "o" }, "н", "y")
map({ "n", "x", "o" }, "г", "u")
map({ "n", "x", "o" }, "ш", "i")
map({ "n", "x", "o" }, "щ", "o")
map({ "n", "x", "o" }, "з", "p")
map({ "n", "x", "o" }, "х", "[")
map({ "n", "x", "o" }, "ъ", "]")

map({ "n", "x", "o" }, "Й", "Q")
map({ "n", "x", "o" }, "Ц", "W")
map({ "n", "x", "o" }, "У", "E")
map({ "n", "x", "o" }, "К", "R")
map({ "n", "x", "o" }, "Е", "T")
map({ "n", "x", "o" }, "Н", "Y")
map({ "n", "x", "o" }, "Г", "U")
map({ "n", "x", "o" }, "Ш", "I")
map({ "n", "x", "o" }, "Щ", "O")
map({ "n", "x", "o" }, "З", "P")
map({ "n", "x", "o" }, "Х", "{")
map({ "n", "x", "o" }, "Ъ", "}")

map({ "n", "x", "o" }, "ф", "a")
map({ "n", "x", "o" }, "ы", "s")
map({ "n", "x", "o" }, "в", "d")
map({ "n", "x", "o" }, "а", "f")
map({ "n", "x", "o" }, "п", "g")
map({ "n", "x", "o" }, "р", "h")
map({ "n", "x", "o" }, "о", "j")
map({ "n", "x", "o" }, "л", "k")
map({ "n", "x", "o" }, "д", "l")
map({ "n", "x", "o" }, "ж", ";")
map({ "n", "x", "o" }, "э", "'")

map({ "n", "x", "o" }, "Ф", "A")
map({ "n", "x", "o" }, "Ы", "S")
map({ "n", "x", "o" }, "В", "D")
map({ "n", "x", "o" }, "А", "F")
map({ "n", "x", "o" }, "П", "G")
map({ "n", "x", "o" }, "Р", "H")
map({ "n", "x", "o" }, "О", "J")
map({ "n", "x", "o" }, "Л", "K")
map({ "n", "x", "o" }, "Д", "L")
map({ "n", "x", "o" }, "Ж", ":")
map({ "n", "x", "o" }, "Э", '"')

map({ "n", "x", "o" }, "я", "z")
map({ "n", "x", "o" }, "ч", "x")
map({ "n", "x", "o" }, "с", "c")
map({ "n", "x", "o" }, "м", "v")
map({ "n", "x", "o" }, "и", "b")
map({ "n", "x", "o" }, "т", "n")
map({ "n", "x", "o" }, "ь", "m")
map({ "n", "x", "o" }, "б", ",")
map({ "n", "x", "o" }, "ю", ".")

map({ "n", "x", "o" }, "Я", "Z")
map({ "n", "x", "o" }, "Ч", "X")
map({ "n", "x", "o" }, "С", "C")
map({ "n", "x", "o" }, "М", "V")
map({ "n", "x", "o" }, "И", "B")
map({ "n", "x", "o" }, "Т", "N")
map({ "n", "x", "o" }, "Ь", "M")
map({ "n", "x", "o" }, "Б", "<")
map({ "n", "x", "o" }, "Ю", ">")

-- vimrc

map("n", "U", "<C-r>", { noremap = true, silent = true })

map("n", "<M-h>", "20h", { noremap = true, silent = true })
map("n", "<M-j>", "10j", { noremap = true, silent = true })
map("n", "<M-k>", "10k", { noremap = true, silent = true })
map("n", "<M-l>", "20l", { noremap = true, silent = true })

map("n", "H", "20h", { noremap = true, silent = true })
map("n", "J", "10j", { noremap = true, silent = true })
map("n", "K", "10k", { noremap = true, silent = true })
map("n", "L", "20l", { noremap = true, silent = true })

map({ "n", "v" }, "d", '"_d', { noremap = true, silent = true })
map({ "n", "v" }, "D", '"_D', { noremap = true, silent = true })
map("n", "x", '"_x', { noremap = true, silent = true })
map("n", "X", '"_X', { noremap = true, silent = true })
map({ "n", "v" }, "c", '"_c', { noremap = true, silent = true })
map({ "n", "v" }, "C", '"_C', { noremap = true, silent = true })

map({ "n", "v" }, "<Tab>", "<cmd>tabnext<cr>", { noremap = true, silent = true })
map({ "n", "v" }, "<S-Tab>", "<cmd>tabprevious<cr>", { noremap = true, silent = true })
