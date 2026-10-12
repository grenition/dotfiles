-- Inline "N refs" counts above definitions in Python and Go files.
--
-- Neither pyright (no codeLensProvider) nor current gopls (the references
-- code lens was removed in gopls v0.23) can serve reference-count lenses,
-- but both answer textDocument/references. This module mirrors the core
-- codelens look (virtual lines above the symbol row, LspCodeLens highlight)
-- using document symbols plus per-symbol references requests.
local M = {}

local api = vim.api

local ns = api.nvim_create_namespace("config.refcounts")

local FILETYPES = { python = true, go = true }

local DEBOUNCE_MS = 750
-- pyright needs a moment to index before references resolve; wait longer on
-- the initial attach.
local ATTACH_DELAY_MS = 1000
-- Huge generated files are not worth dozens of reference requests.
local MAX_SYMBOLS = 250

---@type table<integer, uv.uv_timer_t> bufnr -> debounce timer
local timers = {}
---@type table<integer, integer> bufnr -> refresh generation
local generation = {}

-- lsp.SymbolKind: Module=2, Namespace=3, Class=5, Method=6, Interface=11,
-- Function=12, Struct=23.
local TARGET_KINDS = { [5] = true, [6] = true, [11] = true, [12] = true, [23] = true }
-- Kinds whose children may contain further targets. Deliberately excludes
-- Function/Method: descending into a function body is what pulls in local
-- (nested) functions and blows up the request count.
local CONTAINER_KINDS = { [2] = true, [3] = true, [5] = true, [10] = true, [11] = true, [23] = true }

local function resolve_bufnr(bufnr)
  if not bufnr or bufnr == 0 then
    return api.nvim_get_current_buf()
  end
  return bufnr
end

local function reference_client(bufnr)
  return vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/references" })[1]
end

local function close_timer(bufnr)
  local timer = timers[bufnr]
  if timer then
    timers[bufnr] = nil
    if not timer:is_closing() then
      timer:stop()
      timer:close()
    end
  end
end

local function schedule(bufnr, delay)
  local timer = timers[bufnr]
  if timer and not timer:is_closing() then
    timer:stop()
  else
    timer = vim.uv.new_timer()
    timers[bufnr] = timer
  end
  timer:start(
    delay,
    0,
    vim.schedule_wrap(function()
      M.refresh(bufnr)
    end)
  )
end

--- Recursively collect Class/Method/Function symbols, descending only into
--- class-like containers so local functions stay out.
---@param symbols lsp.SymbolInformation[]|lsp.DocumentSymbol[]
---@param out lsp.DocumentSymbol[]
---@return lsp.DocumentSymbol[]
local function collect_symbols(symbols, out)
  for _, sym in ipairs(symbols or {}) do
    local kind = sym.kind
    if TARGET_KINDS[kind] then
      table.insert(out, sym)
    end
    if CONTAINER_KINDS[kind] and sym.children then
      collect_symbols(sym.children, out)
    end
  end
  return out
end

--- Fetch reference counts and render them as virtual lines. Exposed for
--- tests and manual refresh; normal use goes through the autocmds below.
function M.refresh(bufnr)
  bufnr = resolve_bufnr(bufnr)
  if not api.nvim_buf_is_valid(bufnr) or not FILETYPES[vim.bo[bufnr].filetype] then
    return
  end
  local client = reference_client(bufnr)
  if not client or not client:supports_method("textDocument/documentSymbol", bufnr) then
    return
  end

  api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  generation[bufnr] = (generation[bufnr] or 0) + 1
  local gen = generation[bufnr]

  local text_document = vim.lsp.util.make_text_document_params(bufnr)
  client:request("textDocument/documentSymbol", { textDocument = text_document }, function(err, symbols)
    if gen ~= generation[bufnr] or err or type(symbols) ~= "table" then
      return
    end
    local targets = collect_symbols(symbols, {})
    if #targets == 0 or #targets > MAX_SYMBOLS then
      return
    end

    for _, sym in ipairs(targets) do
      local row = sym.range.start.line
      local start = sym.selectionRange and sym.selectionRange.start or sym.range.start
      local params = {
        textDocument = text_document,
        position = start,
        context = { includeDeclaration = false },
      }
      client:request("textDocument/references", params, function(ref_err, locations)
        if gen ~= generation[bufnr] or not api.nvim_buf_is_valid(bufnr) then
          return
        end
        if ref_err or vim.lsp.get_client_by_id(client.id) ~= client then
          return
        end
        local count = type(locations) == "table" and #locations or 0
        api.nvim_buf_set_extmark(bufnr, ns, row, 0, {
          virt_lines = { { { count .. " refs", "LspCodeLens" } } },
          virt_lines_above = true,
          hl_mode = "combine",
        })
      end, bufnr)
    end
  end, bufnr)
end

--- Remove all refcount marks and close the buffer's debounce timer.
function M.clear(bufnr)
  bufnr = resolve_bufnr(bufnr)
  close_timer(bufnr)
  generation[bufnr] = nil
  if api.nvim_buf_is_valid(bufnr) then
    api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  end
end

function M.setup()
  local group = api.nvim_create_augroup("config.refcounts", { clear = true })

  api.nvim_create_autocmd("LspAttach", {
    group = group,
    callback = function(args)
      if FILETYPES[vim.bo[args.buf].filetype] then
        schedule(args.buf, ATTACH_DELAY_MS)
      end
    end,
  })

  api.nvim_create_autocmd("LspDetach", {
    group = group,
    callback = function(args)
      if not reference_client(args.buf) then
        M.clear(args.buf)
      end
    end,
  })

  api.nvim_create_autocmd({ "InsertLeave", "BufWritePost" }, {
    group = group,
    callback = function(args)
      if FILETYPES[vim.bo[args.buf].filetype] and reference_client(args.buf) then
        schedule(args.buf, DEBOUNCE_MS)
      end
    end,
  })

  api.nvim_create_autocmd("FileType", {
    group = group,
    callback = function(args)
      if FILETYPES[vim.bo[args.buf].filetype] and reference_client(args.buf) then
        schedule(args.buf, DEBOUNCE_MS)
      end
    end,
  })

  api.nvim_create_autocmd({ "BufDelete", "BufUnload", "BufWipeout" }, {
    group = group,
    callback = function(args)
      M.clear(args.buf)
    end,
  })

  -- Lifecycle rule: no libuv handle may outlive the session.
  api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
      for bufnr in pairs(timers) do
        close_timer(bufnr)
      end
    end,
  })
end

return M
