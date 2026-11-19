-- Keys that need no plugin. Plugin keys sit with their plugin's module;
-- Neovim's own LSP keys (grn, gra, grr, gri, gO, K, [d, ]d) are kept as is.

local map = vim.keymap.set

map("n", "<Esc>", "<Cmd>nohlsearch<CR>")

-- Windows, without the <C-w>.
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- Tab through the completion menu while it's open.
map("i", "<Tab>", function()
  return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>"
end, { expr = true })
map("i", "<S-Tab>", function()
  return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
end, { expr = true })

-- Selections keep their place when indented.
map("x", "<", "<gv")
map("x", ">", ">gv")
