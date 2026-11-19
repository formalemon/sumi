-- Fuzzy finding: files, text, buffers, help and more, with mini.pick.
-- Uses rg or fd when installed, otherwise git, otherwise Neovim alone.

local pick = require("mini.pick")
local extra = require("mini.extra")

pick.setup({
  -- A centred window, not a strip in the corner.
  window = {
    config = function()
      local height = math.floor(0.5 * vim.o.lines)
      local width = math.floor(0.6 * vim.o.columns)
      return {
        anchor = "NW",
        height = height,
        width = width,
        row = math.floor((vim.o.lines - height) / 2),
        col = math.floor((vim.o.columns - width) / 2),
      }
    end,
    prompt_prefix = "\u{f002}  ",
  },
})
extra.setup()

-- Anything asking to choose (code actions, vim.ui.select) gets the picker.
vim.ui.select = pick.ui_select

local map = function(lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, { desc = desc })
end
map("<leader>f", pick.builtin.files, "Files")
map("<leader>/", pick.builtin.grep_live, "Grep")
map("<leader>b", pick.builtin.buffers, "Buffers")
map("<leader>h", pick.builtin.help, "Help")
map("<leader>r", pick.builtin.resume, "Resume picker")
map("<leader>o", extra.pickers.oldfiles, "Recent files")
map("<leader>d", extra.pickers.diagnostic, "Diagnostics")
map("<leader>s", function() extra.pickers.lsp({ scope = "document_symbol" }) end, "Symbols")
map("<leader>S", function() extra.pickers.lsp({ scope = "workspace_symbol" }) end, "Workspace symbols")
