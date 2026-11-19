-- Changed lines against git, as thin bars in the sign column (mini.diff).
-- ]h and [h move between hunks, gh applies one, gH resets it, and
-- <leader>gd overlays the old text.

local diff = require("mini.diff")

diff.setup({
  view = {
    style = "sign",
    signs = { add = "▎", change = "▎", delete = "▁" },
  },
  mappings = {
    goto_prev = "[h",
    goto_next = "]h",
    goto_first = "[H",
    goto_last = "]H",
  },
})

vim.keymap.set("n", "<leader>gd", diff.toggle_overlay, { desc = "Git diff overlay" })
