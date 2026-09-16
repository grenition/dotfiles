-- In-terminal image rendering through the snacks.nvim image module, which
-- speaks the Kitty Graphics Protocol supported by Ghostty. PNG renders
-- natively; other formats are converted with ImageMagick's `magick` CLI
-- when it is installed and simply skip rendering when it is not. No eager
-- load order is declared, so snacks stays lazy until something like the
-- neo-tree preview (lua/config/neo_tree_preview.lua) requires it.
return {
  "folke/snacks.nvim",
  opts = {
    image = {
      -- Only enable rendering itself: the math module shells out to
      -- latex/typst compilers, which is unwanted subprocess machinery
      -- here. Everything else keeps snacks defaults.
      math = { enabled = false },
    },
  },
  -- A custom config function replaces lazy.nvim's default handler, so
  -- snacks.setup must be called explicitly here.
  config = function(_, opts)
    require("snacks").setup(opts)

    -- Upstream bug workaround, snacks.nvim locked at 882c996c (== main at
    -- the time of writing; no upstream fix). M:error()
    -- (image/placement.lua:136) assigns `vim.bo[self.buf].modifiable`
    -- without the buffer-validity guard its siblings M:progress (:156)
    -- and M:del (:196) have, and image.lua:127 calls it from a
    -- vim.schedule loop over placements. When image conversion fails on
    -- a buffer that was already wiped (e.g. a neo-tree preview buffer
    -- deleted on navigation), that crashes with "Invalid buffer id".
    -- Placement instances dispatch methods through the module table
    -- (`M.__index = M`, created via `setmetatable({}, M)`), so
    -- replacing the module-level `error` covers every instance; the
    -- shim runs after setup and degrades silently on dead buffers.
    -- Remove it once a fixed upstream release lands.
    local placement = require("snacks.image.placement")
    local upstream_error = placement.error
    placement.error = function(self, ...)
      if not vim.api.nvim_buf_is_valid(self.buf) then
        return
      end
      return upstream_error(self, ...)
    end
  end,
}
