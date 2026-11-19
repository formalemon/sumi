-- Projects: the working directory follows the file you're in to the root of
-- its project, so the tree, the pickers and the language servers all see
-- the same one. Each project entered is remembered for the start screen.

local M = {}

-- What marks a project's root, nearest first in this order.
M.markers = { ".git", "Cargo.lock", "Cargo.toml", "package.json", "go.mod", "pyproject.toml", "Makefile" }

local home = vim.fn.expand("~")
local store = vim.fn.stdpath("state") .. "/projects.json"
local keep = 20

-- A root of yours: under home, and not in a hidden directory, so jumping
-- into ~/.cargo/registry or a plugin's source doesn't count as a project.
local function ours(dir)
  if not dir or dir == home or dir:sub(1, #home + 1) ~= home .. "/" then
    return false
  end
  return not dir:sub(#home + 2):find("^%.") and not dir:find("/%.", #home + 1)
end

function M.root(path)
  local root = vim.fs.root(path, M.markers)
  return ours(root) and root or nil
end

local function load()
  local file = io.open(store, "r")
  if not file then
    return {}
  end
  local ok, list = pcall(vim.json.decode, file:read("*a"))
  file:close()
  return ok and type(list) == "table" and list or {}
end

function M.remember(dir)
  local list = { dir }
  for _, d in ipairs(load()) do
    if d ~= dir and #list < keep then
      table.insert(list, d)
    end
  end
  vim.fn.mkdir(vim.fs.dirname(store), "p")
  local file = io.open(store, "w")
  if file then
    file:write(vim.json.encode(list))
    file:close()
  end
end

-- The most recent projects: the ones remembered, then the roots of
-- recently edited files, each once and only if it's still there.
function M.recent(n)
  local list, seen = {}, {}
  local function add(dir)
    if dir and not seen[dir] and #list < n and vim.fn.isdirectory(dir) == 1 then
      seen[dir] = true
      table.insert(list, dir)
    end
  end
  for _, dir in ipairs(load()) do
    add(dir)
  end
  for _, file in ipairs(vim.v.oldfiles) do
    if #list >= n then
      break
    end
    if file:sub(1, 1) == "/" then
      add(M.root(file))
    end
  end
  return list
end

-- The file last edited in a project, to reopen it there.
function M.last_file(dir)
  for _, file in ipairs(vim.v.oldfiles) do
    if file:sub(1, #dir + 1) == dir .. "/" and vim.fn.filereadable(file) == 1 then
      return file
    end
  end
end

function M.enter(dir)
  if dir ~= vim.fn.getcwd() then
    vim.fn.chdir(dir)
  end
  M.remember(dir)
end

vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("sumi.project", { clear = true }),
  callback = function(ev)
    if vim.bo[ev.buf].buftype ~= "" then
      return
    end
    local name = vim.api.nvim_buf_get_name(ev.buf)
    if name == "" or not vim.uv.fs_stat(name) then
      return
    end
    local root = M.root(name)
    if root and root ~= vim.fn.getcwd() then
      M.enter(root)
    end
  end,
})

return M
