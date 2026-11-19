-- Tree-sitter: highlighting and folds from a real parse, for any language
-- nvim-treesitter knows. A file in a language without a parser gets one
-- built the first time it's opened (needs tree-sitter-cli and a C compiler).

local ts = require("nvim-treesitter")
local can_build = vim.fn.executable("tree-sitter") == 1

-- The languages this machine is mostly written in, ready before they're
-- opened. A no-op once they're installed.
if can_build then
  ts.install({
    "bash", "css", "diff", "git_config", "gitcommit", "git_rebase",
    "gitignore", "json", "kdl", "rust", "toml", "yaml",
  })
end

local function start(buf, lang)
  if not pcall(vim.treesitter.start, buf, lang) then
    return false
  end
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    vim.wo[win][0].foldmethod = "expr"
    vim.wo[win][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.wo[win][0].foldlevel = 99
  end
  return true
end

local available -- language -> true, read once, when first needed

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("sumi.treesitter", { clear = true }),
  callback = function(ev)
    local lang = vim.treesitter.language.get_lang(ev.match) or ev.match
    if start(ev.buf, lang) or not can_build then
      return
    end
    if not available then
      available = {}
      for _, l in ipairs(ts.get_available()) do
        available[l] = true
      end
    end
    if available[lang] then
      ts.install(lang):await(function(err)
        if not err then
          vim.schedule(function()
            if vim.api.nvim_buf_is_valid(ev.buf) then
              start(ev.buf, lang)
            end
          end)
        end
      end)
    end
  end,
})
