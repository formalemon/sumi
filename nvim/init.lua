-- Neovim. Colours come from enso, through rose-pine/neovim.

vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true
vim.o.signcolumn = "yes"
vim.o.termguicolors = true

-- Neovim's own plugin manager (0.12+); installs on first start.
vim.pack.add({ { src = "https://github.com/rose-pine/neovim", name = "rose-pine" } }, { confirm = false })

-- No background of Neovim's own: the terminal's, translucent, shows through.
require("rose-pine").setup({ styles = { transparency = true } })

-- The active enso theme; follows `enso-ctl theme set` while running.
local theme = vim.fn.expand("~/.local/state/enso/nvim.lua")
if vim.uv.fs_stat(theme) then
  dofile(theme)
else
  -- Without enso: Rosé Pine Moon, as sumi is dressed.
  vim.cmd.colorscheme("rose-pine-moon")
end
