-- Neovim, in pieces. Each module under lua/sumi/ does one thing and can be
-- dropped by deleting its line here; servers live in lsp/, one per file.

-- Lua modules, compiled and cached: a faster start.
vim.loader.enable()

require("sumi.options")    -- how the editor behaves and looks
require("sumi.keymaps")    -- keys that need no plugin
require("sumi.autocmds")   -- yank flash, last position
require("sumi.pack")       -- the plugins, through vim.pack, pinned in the lock
require("sumi.theme")      -- rose-pine, coloured by enso when it's there
require("sumi.statusline") -- one line, no plugin
require("sumi.treesitter") -- highlighting and folds; parsers fetched as needed
require("sumi.project")    -- the working directory follows the project
require("sumi.pick")       -- files, grep, buffers, help: mini.pick
require("sumi.git")        -- changed lines in the gutter: mini.diff
require("sumi.lsp")        -- servers from lsp/, completion, diagnostics
require("sumi.tree")       -- the project as a sidebar: nvim-tree
require("sumi.start")      -- an ensō and recent projects, when started bare
require("sumi.clue")       -- what can follow <Space>, g, z, [ ], when you pause
