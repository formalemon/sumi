-- Colours come from enso, through rose-pine/neovim.

-- No background of Neovim's own: the terminal's, translucent, shows through.
require("rose-pine").setup({
  styles = { transparency = true, italic = false },
})

-- The active enso theme; follows `enso-ctl theme set` while running.
local theme = vim.fn.expand("~/.local/state/enso/nvim.lua")
if vim.uv.fs_stat(theme) then
  dofile(theme)
else
  -- Without enso: Rosé Pine Moon, as sumi is dressed.
  vim.cmd.colorscheme("rose-pine-moon")
end

-- Nerd Font icons, in the theme's colours; plugins asking for
-- nvim-web-devicons get these instead.
require("mini.icons").setup()
MiniIcons.mock_nvim_web_devicons()
