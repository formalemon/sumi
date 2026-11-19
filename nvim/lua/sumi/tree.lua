-- The project as a sidebar, with nvim-tree. Rooted where the working
-- directory is, which sumi.project keeps at the project's root. Git state
-- colours the names; ? lists the keys (a add, r rename, d delete, H dotfiles,
-- I git-ignored files).

local api = require("nvim-tree.api")

local sev = vim.diagnostic.config().signs.text or {}

require("nvim-tree").setup({
  hijack_cursor = true,
  sync_root_with_cwd = true,
  update_focused_file = { enable = true },
  view = { width = 32, signcolumn = "no" },
  renderer = {
    root_folder_label = ":t",
    special_files = {},
    highlight_git = "name",
    indent_markers = { enable = true },
    icons = {
      git_placement = "after",
      diagnostics_placement = "after",
      modified_placement = "after",
      show = { git = false, folder_arrow = false },
      glyphs = {
        modified = "●",
        folder = { default = "\u{f07b}", open = "\u{f07c}", empty = "\u{f07b}", empty_open = "\u{f07c}" },
      },
    },
  },
  modified = { enable = true },
  diagnostics = {
    enable = true,
    show_on_dirs = true,
    icons = {
      error = sev[vim.diagnostic.severity.ERROR] or "E",
      warning = sev[vim.diagnostic.severity.WARN] or "W",
      info = sev[vim.diagnostic.severity.INFO] or "I",
      hint = sev[vim.diagnostic.severity.HINT] or "H",
    },
  },
  filters = { custom = { "^\\.git$" } },
})

vim.keymap.set("n", "<leader>e", function()
  api.tree.toggle({ find_file = true })
end, { desc = "Project tree" })

-- :q in the last window of your own closes the tree with it, instead of
-- leaving the tree alone on screen.
vim.api.nvim_create_autocmd("QuitPre", {
  group = vim.api.nvim_create_augroup("sumi.tree", { clear = true }),
  callback = function()
    local current = vim.api.nvim_get_current_win()
    local others = vim.tbl_filter(function(win)
      return win ~= current and vim.api.nvim_win_get_config(win).relative == ""
    end, vim.api.nvim_tabpage_list_wins(0))
    if #others == 1 and vim.bo[vim.api.nvim_win_get_buf(others[1])].filetype == "NvimTree" then
      api.tree.close()
    end
  end,
})
