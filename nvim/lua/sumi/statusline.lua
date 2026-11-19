-- One statusline for every window, no plugin: the file on the left; git
-- changes, diagnostics and the cursor's place on the right.

local M = {}

local sev = vim.diagnostic.severity
local diagnostics = {
  { sev.ERROR, "DiagnosticError", "\u{f057} " },
  { sev.WARN, "DiagnosticWarn", "\u{f071} " },
  { sev.INFO, "DiagnosticInfo", "\u{f05a} " },
  { sev.HINT, "DiagnosticHint", "\u{f0335} " },
}

local function escape(s)
  return (s:gsub("%%", "%%%%"))
end

function M.render()
  local buf = vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0)
  local name = vim.api.nvim_buf_get_name(buf)
  local left, right = { " " }, {}

  -- The start screen has none; the tree shows the project it's rooted in.
  local ft = vim.bo[buf].filetype
  if ft == "sumistart" then
    return ""
  elseif ft == "NvimTree" then
    return " %#Directory#\u{f07b} %*" .. escape(vim.fs.basename(vim.fn.getcwd()))
  end

  -- The file: icon, path from the working directory, a dot when modified.
  local path = name == "" and "[No Name]" or vim.fn.fnamemodify(name, ":~:.")
  if _G.MiniIcons and name ~= "" then
    local icon, hl = MiniIcons.get("file", name)
    table.insert(left, ("%%#%s#%s %%*"):format(hl, icon))
  end
  table.insert(left, escape(path))
  if vim.bo[buf].modified then
    table.insert(left, " %#DiagnosticWarn#●%*")
  elseif vim.bo[buf].readonly or not vim.bo[buf].modifiable then
    table.insert(left, " %#Comment#\u{f033e}%*")
  end

  -- Lines added, changed and removed against git, from mini.diff.
  local diff = vim.b[buf].minidiff_summary
  if diff then
    for _, part in ipairs({
      { diff.add, "Added", "+" },
      { diff.change, "Changed", "~" },
      { diff.delete, "Removed", "-" },
    }) do
      if (part[1] or 0) > 0 then
        table.insert(right, ("%%#%s#%s%d%%*"):format(part[2], part[3], part[1]))
      end
    end
  end

  -- Diagnostics, by severity.
  local counts = vim.diagnostic.count(buf)
  for _, d in ipairs(diagnostics) do
    if counts[d[1]] then
      table.insert(right, ("%%#%s#%s%d%%*"):format(d[2], d[3], counts[d[1]]))
    end
  end

  table.insert(right, "%#Comment#%l:%c%* ")
  return table.concat(left) .. "%=" .. table.concat(right, "  ")
end

vim.o.statusline = "%!v:lua.require'sumi.statusline'.render()"

local group = vim.api.nvim_create_augroup("sumi.statusline", { clear = true })
local redraw = function()
  vim.cmd.redrawstatus()
end
vim.api.nvim_create_autocmd("DiagnosticChanged", { group = group, callback = redraw })
vim.api.nvim_create_autocmd("User", { group = group, pattern = "MiniDiffUpdated", callback = redraw })

return M
