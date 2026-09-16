local map = vim.keymap.set
local tools = require("config.tool_windows")
local undoredo = require("config.undoredo")

tools.setup()

-- Space is only a leader prefix; never fall back to its default `l` motion.
map("n", "<Space>", "<Nop>", { silent = true })

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

-- One float for <leader>k: any diagnostic at the cursor first, then the
-- symbol's hover documentation below a separator.
local function hover_with_diagnostics()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1], cursor[2]
  local lines = {}
  for _, diagnostic in ipairs(vim.diagnostic.get(0, { lnum = row - 1 })) do
    if col >= diagnostic.col and col <= diagnostic.end_col then
      local severity = vim.diagnostic.severity[diagnostic.severity] or "INFO"
      table.insert(lines, severity .. ": " .. diagnostic.message)
    end
  end
  local has_diagnostics = #lines > 0

  local hover = {}
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0, method = "textDocument/hover" })) do
    -- Clients disagree on offset encoding (pyright uses utf-16, ruff utf-8),
    -- so each request must carry its own encoding.
    local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
    local results = vim.lsp.buf_request_sync(0, "textDocument/hover", params, 1000, client.id)
    local result = results and results[client.id]
    local contents = result and result.result and result.result.contents
    if contents then
      for _, line in ipairs(vim.lsp.util.convert_input_to_markdown_lines(contents)) do
        if line:match("%S") then
          table.insert(hover, line)
        end
      end
    end
  end

  -- Some servers answer an empty hover with a bare fenced-language marker
  -- such as ```Python; a hover made only of fence lines is not documentation.
  local has_hover = false
  for _, line in ipairs(hover) do
    if not line:match("^%s*```") then
      has_hover = true
    end
  end
  if has_hover then
    if has_diagnostics then
      table.insert(lines, "---")
    end
    for _, line in ipairs(hover) do
      table.insert(lines, line)
    end
  end
  if #lines == 0 then
    vim.notify("No documentation or diagnostics at cursor", vim.log.levels.INFO)
    return
  end
  -- Returns (bufnr, winnr); mind the order.
  local buf, win = vim.lsp.util.open_floating_preview(lines, "markdown", {
    border = "rounded",
    wrap = true,
    max_width = math.floor(vim.o.columns * 0.6),
    max_height = math.floor(vim.o.lines * 0.6),
  })
  -- Disarm core's global WinClosed bookkeeping immediately: its callback
  -- dereferences window-scoped vars of whatever window closes next and can
  -- crash on windows torn down inside other close handlers. Losing it only
  -- leaves a stale lsp_floating_preview var, which the next open already
  -- guards against.
  pcall(vim.api.nvim_del_augroup_by_name, "nvim.closing_floating_preview")
  -- The preview only auto-closes on cursor moves; Esc/q close it explicitly.
  -- The float never receives focus (nvim_open_win enter=false), so Esc must
  -- be mapped on the SOURCE buffer; it cleans itself up once the float is
  -- gone through any other close path.
  if win and vim.api.nvim_win_is_valid(win) and vim.api.nvim_buf_is_valid(buf) then
    for _, key in ipairs({ "<Esc>", "q" }) do
      vim.keymap.set("n", key, function()
        pcall(vim.api.nvim_win_close, win, true)
      end, { buffer = buf, nowait = true, silent = true })
    end
    local source = vim.api.nvim_get_current_buf()
    if vim.api.nvim_buf_is_valid(source) and source ~= buf then
      vim.keymap.set("n", "<Esc>", function()
        if vim.api.nvim_win_is_valid(win) then
          pcall(vim.api.nvim_win_close, win, true)
        end
        pcall(vim.keymap.del, "n", "<Esc>", { buffer = source })
      end, { buffer = source, nowait = true, silent = true })
    end
  end
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
map("n", "<leader>gg", function()
  require("fzf-lua").git_status({ cwd = project_root() })
end, { desc = "Git changes" })

-- Search
map("n", "<leader>ff", function()
  require("fzf-lua").files({ cwd = project_root() })
end, { desc = "Files" })
map("n", "<C-p>", function()
  require("fzf-lua").files({ cwd = project_root() })
end, { desc = "Files" })
map("n", "<leader><leader>", function()
  require("fzf-lua").buffers()
end, { desc = "Open buffers" })
map("n", "<leader>fg", function()
  require("fzf-lua").live_grep({ cwd = project_root() })
end, { desc = "Grep" })
map("n", "<leader>fc", function()
  require("fzf-lua").live_grep({ cwd = project_root() })
end, { desc = "Grep" })
map("n", "<leader>fr", function()
  require("fzf-lua").oldfiles()
end, { desc = "Recent files" })
map("n", "<leader>fd", function()
  require("fzf-lua").diagnostics_document()
end, { desc = "Document diagnostics" })
map("n", "<leader>ft", function()
  require("fzf-lua").grep({ cwd = project_root(), search = "TODO|FIXME|HACK" })
end, { desc = "TODOs" })
map("n", "<leader>nt", function()
  require("fzf-lua").commands()
end, { desc = "Commands" })
map("n", "<leader>0", function()
  require("fzf-lua").lsp_document_symbols()
end, { desc = "File structure" })
map("n", "<M-j>", function()
  require("fzf-lua").lsp_document_symbols()
end, { desc = "File structure" })
map("n", "<M-k>", function()
  require("fzf-lua").lsp_document_symbols()
end, { desc = "File structure" })
map("n", "<leader>ud", function()
  require("config.theme").pick("light")
end, { desc = "Choose light UI theme" })
map("n", "<leader>un", function()
  require("config.theme").pick("dark")
end, { desc = "Choose dark UI theme" })
map("n", "<leader>uh", function()
  require("config.lsp_ui").pick("inlay_hints")
end, { desc = "Configure inlay hints" })
map("n", "<leader>ul", function()
  require("config.lsp_ui").pick("code_lens")
end, { desc = "Configure CodeLens references" })

-- LSP
map("n", "gd", require("config.navigation").goto_definition, { desc = "Definition, file, or URL" })
map("n", "gr", function()
  require("fzf-lua").lsp_references()
end, { desc = "References" })
map("n", "gD", function()
  require("fzf-lua").lsp_typedefs()
end, { desc = "Type definition" })
map("n", "gi", function()
  require("fzf-lua").lsp_implementations()
end, { desc = "Implementations" })
map("n", "gu", function()
  require("fzf-lua").lsp_references()
end, { desc = "Usages" })
map("n", "<BS>", "<C-o>", { desc = "Jump back" })
map("n", "<S-BS>", "<C-i>", { desc = "Jump forward" })
map("n", "<leader>rr", vim.lsp.buf.rename, { desc = "Rename symbol" })
map("n", "<leader>k", hover_with_diagnostics, { desc = "Documentation and diagnostics" })
map("n", "<leader>i", function()
  require("fzf-lua").lsp_implementations()
end, { desc = "Implementations" })
map("n", "<leader>ur", function()
  require("fzf-lua").lsp_references()
end, { desc = "Usages" })
map({ "n", "i" }, "<C-s>", vim.lsp.buf.signature_help, { desc = "Signature help" })
map({ "n", "x" }, "<leader>a", function()
  require("fzf-lua").lsp_code_actions()
end, { desc = "Code actions" })
map({ "n", "x" }, "<leader>oe", function()
  require("fzf-lua").lsp_code_actions()
end, { desc = "Code actions" })
map("n", "<leader>ol", vim.lsp.codelens.run, { desc = "Run code lens" })
map("n", "<leader>oc", function()
  require("conform").format({ lsp_format = "fallback" })
end, { desc = "Format" })
map("n", "<leader>oi", organize_imports, { desc = "Organize imports" })
map("n", "<leader>oa", function()
  require("conform").format({ lsp_format = "fallback" })
  organize_imports()
end, { desc = "Format and organize imports" })

-- Personal editing preferences
map("n", "u", undoredo.undo, { desc = "Undo" })
map("n", "U", undoredo.redo, { desc = "Redo" })
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

-- macOS-style cursor movement: Insert mode behaves like a plain editor.
-- Ctrl+arrows already move by word natively in Insert mode; Option and Shift
-- arrows are mapped to match. Every common modifier+arrow is mapped in
-- Insert mode on purpose: an unmapped <M-key>/<S-key> would split into a
-- bare Esc and kick Insert mode back to Normal. Cmd+Left/Right/Backspace
-- arrive as Home/End/Ctrl+U through the Ghostty keybinds, Cmd+Up/Down as
-- Ctrl+Up/Down.
map("i", "<M-Left>", "<C-Left>", { desc = "Previous word" })
map("i", "<M-Right>", "<C-Right>", { desc = "Next word" })
-- Shift+arrows (and their Ctrl/Option/Cmd combos) start a native Select-mode
-- selection through 'keymodel=startsel' + 'selectmode=key' (see options.lua):
-- typing or Backspace replaces the selection like in a regular editor, and
-- Ctrl+C copies it to the system clipboard. Visual mode shares the copy and
-- cut binds, Ctrl+X cuts, and Ctrl+V pastes the system clipboard in Insert
-- mode.
map("s", "<C-c>", '<C-o>"+y', { desc = "Copy selection to system clipboard" })
map("x", "<C-c>", '"+y', { desc = "Copy selection to system clipboard" })
map("s", "<C-x>", '<C-o>"+x', { desc = "Cut selection to system clipboard" })
map("x", "<C-x>", '"+x', { desc = "Cut selection to system clipboard" })
map("i", "<C-v>", "<C-r><C-o>+", { desc = "Paste from system clipboard" })
-- Releasing the mouse after a drag yanks the selection to the system
-- clipboard and leaves Visual mode right away, mirroring tmux's
-- MouseDragEnd1Pane copy; TextYankPost gives the same on-yank flash as
-- <C-c>. Plain clicks stay untouched: pressing the left button already
-- stops Visual mode, so only real mouse selections (drag, double-click)
-- reach this map.
map("x", "<LeftRelease>", '"+y', { desc = "Copy mouse selection to system clipboard" })
map("i", "<M-Up>", "<C-o>gk", { desc = "Display line up" })
map("i", "<M-Down>", "<C-o>gj", { desc = "Display line down" })
map({ "n", "x" }, "<M-Left>", "b", { desc = "Previous word" })
map({ "n", "x" }, "<M-Right>", "w", { desc = "Next word" })
map({ "n", "x" }, "<C-Left>", "b", { desc = "Previous word" })
map({ "n", "x" }, "<C-Right>", "w", { desc = "Next word" })
map("i", "<C-BS>", "<C-w>", { desc = "Delete previous word" })
map("i", "<C-h>", "<C-w>", { desc = "Delete previous word" })
map("n", "<C-Up>", "gg", { desc = "First line" })
map("n", "<C-Down>", "G", { desc = "Last line" })
map("i", "<C-Up>", "<C-o>gg", { desc = "First line" })
map("i", "<C-Down>", "<C-o>G", { desc = "Last line" })
