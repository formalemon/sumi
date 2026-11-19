-- The plugins, through Neovim's own manager. They install on first start;
-- nvim-pack-lock.json pins each to a commit, `:lua vim.pack.update()` moves
-- them forward and rewrites it.

-- Parsers have to match nvim-treesitter's queries: rebuild them whenever
-- vim.pack moves it to a new commit. (Defined before add, which can fire it.)
vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("sumi.pack", { clear = true }),
  callback = function(ev)
    if ev.data.spec.name == "nvim-treesitter" and ev.data.kind == "update" then
      if not ev.data.active then
        vim.cmd.packadd("nvim-treesitter")
      end
      vim.cmd("TSUpdate")
    end
  end,
})

vim.pack.add({
  { src = "https://github.com/rose-pine/neovim", name = "rose-pine" },
  -- One repository, many small modules: pick, diff, icons, extra.
  { src = "https://github.com/nvim-mini/mini.nvim" },
  -- The project as a tree in a sidebar.
  { src = "https://github.com/nvim-tree/nvim-tree.lua" },
  -- Parsers and queries for the languages Neovim doesn't ship.
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
}, { confirm = false })
