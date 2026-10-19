---@type LazySpec

-- Visual Studio-inspired C# semantic colors, using AstroTheme's native highlight overrides.
-- AstroTheme owns the UI. auto-dark-mode.nvim owns light/dark switching.
local dark = {
  keyword = "#569CD6",
  control = "#C586C0",
  string = "#CE9178",
  number = "#B5CEA8",
  comment = "#6A9955",
  func = "#DCDCAA",
  type = "#4EC9B0",        -- classes
  interface = "#B8D7A3",   -- interfaces, enums, type parameters
  struct = "#86C691",      -- structs
  namespace = "#D4D4D4",   -- namespaces (Visual Studio, not VS Code Dark+)
  member = "#D4D4D4",      -- fields, properties, enum members, constants
  variable = "#9CDCFE",    -- fallback for non-C# code
  text = "#D4D4D4",
}

local light = {
  keyword = "#0000FF",
  control = "#AF00DB",
  string = "#A31515",
  number = "#098658",
  comment = "#008000",
  func = "#795E26",
  type = "#267F99",
  interface = "#267F99",
  struct = "#267F99",
  namespace = "#222222",
  member = "#222222",
  variable = "#001080",   -- fallback for non-C# code
  text = "#000000",
}

local function visual_studio_highlights(c)
  local function fg(color) return { fg = color } end

  return {
    -- Vim syntax groups (Tree-sitter fallback).
    Comment = { fg = c.comment, italic = true },
    String = fg(c.string),
    Character = fg(c.string),
    Number = fg(c.number),
    Float = fg(c.number),
    Boolean = fg(c.keyword),
    Function = fg(c.func),
    Type = fg(c.type),
    Typedef = fg(c.type),
    Structure = fg(c.struct),
    Identifier = fg(c.variable),
    Constant = fg(c.member),
    Keyword = fg(c.keyword),
    Statement = fg(c.control),
    Conditional = fg(c.control),
    Repeat = fg(c.control),
    Exception = fg(c.control),
    Include = fg(c.keyword),
    PreProc = fg(c.keyword),
    StorageClass = fg(c.keyword),
    Operator = fg(c.text),
    Delimiter = fg(c.text),

    -- Tree-sitter captures.
    ["@comment"] = { fg = c.comment, italic = true },
    ["@string"] = fg(c.string),
    ["@string.escape"] = fg(c.keyword),
    ["@character"] = fg(c.string),
    ["@number"] = fg(c.number),
    ["@number.float"] = fg(c.number),
    ["@boolean"] = fg(c.keyword),
    ["@keyword"] = fg(c.keyword),
    ["@keyword.function"] = fg(c.keyword),
    ["@keyword.import"] = fg(c.keyword),
    ["@keyword.return"] = fg(c.control),
    ["@keyword.conditional"] = fg(c.control),
    ["@keyword.repeat"] = fg(c.control),
    ["@keyword.exception"] = fg(c.control),
    ["@keyword.operator"] = fg(c.keyword),
    ["@function"] = fg(c.func),
    ["@function.call"] = fg(c.func),
    ["@function.builtin"] = fg(c.func),
    ["@function.method"] = fg(c.func),
    ["@function.method.call"] = fg(c.func),
    ["@type"] = fg(c.type),
    ["@type.builtin"] = fg(c.keyword),
    ["@type.definition"] = fg(c.type),
    ["@constructor"] = fg(c.type),
    ["@namespace"] = fg(c.namespace),
    ["@module"] = fg(c.namespace),
    ["@module.builtin"] = fg(c.namespace),
    ["@variable"] = fg(c.variable),
    ["@variable.parameter"] = fg(c.variable),
    ["@variable.member"] = fg(c.member),
    ["@variable.builtin"] = fg(c.keyword),
    ["@property"] = fg(c.member),
    ["@constant"] = fg(c.member),
    ["@constant.builtin"] = fg(c.keyword),
    ["@operator"] = fg(c.text),
    ["@punctuation.delimiter"] = fg(c.text),
    ["@punctuation.bracket"] = fg(c.text),

    -- LSP semantic tokens: distinguish Visual Studio C# symbol kinds.
    ["@lsp.type.namespace"] = fg(c.namespace),
    ["@lsp.type.class"] = fg(c.type),
    ["@lsp.type.interface"] = fg(c.interface),
    ["@lsp.type.struct"] = fg(c.struct),
    ["@lsp.type.enum"] = fg(c.interface),
    ["@lsp.type.type"] = fg(c.type),
    ["@lsp.type.typeParameter"] = fg(c.interface),
    ["@lsp.type.typeAlias"] = fg(c.type),
    ["@lsp.type.function"] = fg(c.func),
    ["@lsp.type.method"] = fg(c.func),
    ["@lsp.type.macro"] = fg(c.func),
    ["@lsp.type.variable"] = fg(c.variable),
    ["@lsp.type.parameter"] = fg(c.variable),
    ["@lsp.type.property"] = fg(c.member),
    ["@lsp.type.enumMember"] = fg(c.member),
    ["@lsp.type.keyword"] = fg(c.keyword),
    ["@lsp.type.string"] = fg(c.string),
    ["@lsp.type.number"] = fg(c.number),
    ["@lsp.type.comment"] = { fg = c.comment, italic = true },
    ["@lsp.typemod.variable.readonly"] = fg(c.member),

    -- C# locals/parameters use ordinary text color in Visual Studio.
    -- Filetype-qualified semantic groups take precedence over generic LSP groups.
    ["@lsp.type.namespace.cs"] = fg(c.namespace),
    ["@lsp.type.variable.cs"] = fg(c.member),
    ["@lsp.type.parameter.cs"] = fg(c.member),
    ["@lsp.type.property.cs"] = fg(c.member),
    ["@variable.cs"] = fg(c.member),
    ["@variable.parameter.cs"] = fg(c.member),
    ["@variable.member.cs"] = fg(c.member),
    ["@property.cs"] = fg(c.member),
  }
end

return {
  {
    "AstroNvim/astroui",
    opts = { colorscheme = "astrotheme" },
  },
  {
    "AstroNvim/astrotheme",
    opts = {
      background = { dark = "astrodark", light = "astrolight" },
      palettes = {
        astrodark = { syntax = { text = dark.text } },
        astrolight = { syntax = { text = light.text } },
      },
      highlights = {
        astrodark = visual_studio_highlights(dark),
        astrolight = visual_studio_highlights(light),
      },
    },
  },
  {
    "f-person/auto-dark-mode.nvim",
    lazy = false,
    opts = { update_interval = 3000 },
  },
}

