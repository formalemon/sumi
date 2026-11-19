-- The start screen, when Neovim opens with nothing to edit: an ensō, your
-- recent projects, and a few keys. A number or <CR> opens a project where
-- you left it, with its tree; f finds a file, n starts a new one, q quits.

local project = require("sumi.project")

local M = {}

local art = {
  "                █▄▄▄",
  "    ▄▄█▀▀       ▀█████",
  "   ██▀            ▀████▄",
  " ▄█▀                ████▄",
  " ██                  ████",
  "██                   ████",
  "██                   ████",
  "██▄                  ████",
  " ███                ████",
  "  ▀██▄            ▄████",
  "   ▀████▄▄▄▄▄▄▄▄█████▀",
  "      ▀███████████▀",
  "           ▀▀▀",
}

local actions = { { "f", "find" }, { "n", "new" }, { "q", "quit" } }

local ns = vim.api.nvim_create_namespace("sumi.start")
local width = vim.fn.strdisplaywidth

-- Lines of { text, group } pieces, laid out in the middle of the window.
local function layout(projects)
  local lines = {}
  local function block(rows)
    local w = 0
    for _, row in ipairs(rows) do
      local n = 0
      for _, piece in ipairs(row) do
        n = n + width(piece[1])
      end
      w = math.max(w, n)
    end
    table.insert(lines, { rows = rows, width = w })
  end

  local rows = {}
  for _, line in ipairs(art) do
    table.insert(rows, { { line, "Function" } })
  end
  block(rows)
  block({ {} })

  rows = {}
  local name_width = 0
  for _, dir in ipairs(projects) do
    name_width = math.max(name_width, width(vim.fs.basename(dir)))
  end
  for i, dir in ipairs(projects) do
    local name = vim.fs.basename(dir)
    table.insert(rows, {
      { tostring(i), "Special" },
      { "  " .. name .. string.rep(" ", name_width - width(name) + 4), "Identifier" },
      { vim.fn.fnamemodify(dir, ":~"), "Comment" },
    })
  end
  if #projects == 0 then
    table.insert(rows, { { "no projects yet", "Comment" } })
  end
  block(rows)
  block({ {} })

  local row = {}
  for i, action in ipairs(actions) do
    table.insert(row, { action[1], "Special" })
    table.insert(row, { " " .. action[2] .. (i < #actions and "    " or ""), "Comment" })
  end
  block({ row })
  return lines
end

local function render(buf, win, state)
  local cols, rows = vim.api.nvim_win_get_width(win), vim.api.nvim_win_get_height(win)
  local blocks = layout(state.projects)

  local text, marks = {}, {}
  local total = 0
  for _, b in ipairs(blocks) do
    total = total + #b.rows
  end
  for _ = 1, math.max(0, math.floor((rows - total) / 2)) do
    table.insert(text, "")
  end

  state.rows = {}
  for i, b in ipairs(blocks) do
    local pad = string.rep(" ", math.max(0, math.floor((cols - b.width) / 2)))
    for _, row in ipairs(b.rows) do
      local line, col = pad, #pad
      for _, piece in ipairs(row) do
        table.insert(marks, { #text, col, col + #piece[1], piece[2] })
        line = line .. piece[1]
        col = col + #piece[1]
      end
      table.insert(text, line)
      if i == 3 and #state.projects > 0 then
        table.insert(state.rows, { #text, #pad })
      end
    end
  end

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, text)
  vim.bo[buf].modifiable = false
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  for _, m in ipairs(marks) do
    vim.api.nvim_buf_set_extmark(buf, ns, m[1], m[2], { end_col = m[3], hl_group = m[4] })
  end
  local at = state.rows[state.index]
  if at then
    vim.api.nvim_win_set_cursor(win, at)
  end
end

local function open_project(dir)
  project.enter(dir)
  local file = project.last_file(dir)
  if file then
    vim.cmd.edit(vim.fn.fnameescape(file))
  else
    vim.cmd.enew()
  end
  require("nvim-tree.api").tree.open({ find_file = true })
  vim.cmd.wincmd("p")
end

function M.open()
  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  local state = { projects = project.recent(9), index = 1 }

  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "sumistart"
  for option, value in pairs({
    number = false, relativenumber = false, cursorline = false, signcolumn = "no",
    list = false, foldcolumn = "0", statuscolumn = "", colorcolumn = "", wrap = false,
  }) do
    vim.wo[win][0][option] = value
  end

  local function map(lhs, rhs)
    vim.keymap.set("n", lhs, rhs, { buffer = buf, nowait = true, silent = true })
  end
  local function move(by)
    return function()
      if #state.rows > 0 then
        state.index = (state.index - 1 + by) % #state.rows + 1
        vim.api.nvim_win_set_cursor(0, state.rows[state.index])
      end
    end
  end
  map("j", move(1))
  map("k", move(-1))
  map("<Down>", move(1))
  map("<Up>", move(-1))
  map("<CR>", function()
    if state.projects[state.index] then
      open_project(state.projects[state.index])
    end
  end)
  for i, dir in ipairs(state.projects) do
    map(tostring(i), function()
      open_project(dir)
    end)
  end
  map("f", function()
    require("mini.pick").builtin.files()
  end)
  map("n", "<Cmd>enew<CR>")
  map("q", "<Cmd>qa<CR>")

  render(buf, win, state)
  vim.api.nvim_create_autocmd({ "VimResized", "WinResized" }, {
    group = vim.api.nvim_create_augroup("sumi.start", { clear = true }),
    callback = function()
      if not vim.api.nvim_buf_is_valid(buf) then
        return true
      end
      local shown = vim.fn.bufwinid(buf)
      if shown ~= -1 then
        render(buf, shown, state)
      end
    end,
  })
end

-- Only for a bare `nvim`: no files, nothing piped in, an empty buffer.
local piped = false
vim.api.nvim_create_autocmd("StdinReadPre", {
  once = true,
  callback = function()
    piped = true
  end,
})
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    if vim.fn.argc() > 0 or piped or #vim.api.nvim_list_uis() == 0 then
      return
    end
    if vim.api.nvim_buf_get_name(buf) ~= "" or vim.bo[buf].modified
      or vim.api.nvim_buf_line_count(buf) > 1 or vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] ~= "" then
      return
    end
    M.open()
  end,
})

return M
