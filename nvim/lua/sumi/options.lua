-- How the editor behaves and looks. Nothing here needs a plugin.

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local o = vim.o

-- Gutter: numbers, relative, and a sign column that never shifts the text.
o.number = true
o.relativenumber = true
o.cursorline = true
o.cursorlineopt = "number"
o.signcolumn = "yes"

-- Chrome: one statusline for all windows, no intro, no ~ past the end,
-- rounded floats like niri's windows and enso's panels.
o.termguicolors = true
o.laststatus = 3
o.showmode = false
o.ruler = false
o.shortmess = o.shortmess .. "I"
o.fillchars = "eob: ,fold: ,foldopen:\u{eab4},foldclose:\u{eab6},foldsep: "
o.winborder = "rounded"
o.pumborder = "rounded"
o.pumheight = 10
o.list = true
o.listchars = "tab:  ,trail:·,nbsp:␣"

-- Text.
o.wrap = false
o.breakindent = true
o.scrolloff = 8
o.sidescrolloff = 8
o.smoothscroll = true
o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.smartindent = true

-- Search and substitute: case only when asked for, previews as you type.
o.ignorecase = true
o.smartcase = true
o.inccommand = "split"

-- Windows open where the eye goes next.
o.splitright = true
o.splitbelow = true

-- Files: persistent undo, ask instead of failing on :q with changes.
o.undofile = true
o.confirm = true
o.updatetime = 250

-- Completion as you type, from the language server first, then the words
-- in this buffer, the other windows and the other buffers.
o.autocomplete = true
o.complete = "o,.^5,w^5,b^5"
o.completeopt = "menuone,noselect,fuzzy,popup"

-- The system clipboard, through wl-copy; set after start-up so finding the
-- provider doesn't hold it up.
vim.schedule(function()
  o.clipboard = "unnamedplus"
end)
