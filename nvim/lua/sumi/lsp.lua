-- Language servers: each one's settings are a file in lsp/, named for it,
-- and it starts only if its program is installed. Neovim's defaults give
-- the keys: K hover, grn rename, gra actions, grr references, gri
-- implementation, gO symbols, [d ]d diagnostics, <C-s> signature help.

-- Diagnostics: the message beside the line the cursor is on, not every line.
vim.diagnostic.config({
  severity_sort = true,
  virtual_text = { current_line = true, prefix = "●", spacing = 2 },
  float = { source = "if_many" },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "\u{f057}",
      [vim.diagnostic.severity.WARN] = "\u{f071}",
      [vim.diagnostic.severity.INFO] = "\u{f05a}",
      [vim.diagnostic.severity.HINT] = "\u{f0335}",
    },
  },
})

-- Whether a program is really there. rustup puts a proxy on PATH for each
-- of its components, installed or not; look in the toolchains for those.
local function installed(program)
  local path = vim.fn.exepath(program)
  if path == "" then
    return false
  end
  if vim.fs.basename(vim.uv.fs_realpath(path) or path) ~= "rustup" then
    return true
  end
  local home = vim.env.RUSTUP_HOME or vim.fn.expand("~/.rustup")
  return vim.fn.glob(home .. "/toolchains/*/bin/" .. program) ~= ""
end

-- Every server with a file in lsp/ and its program installed.
for _, file in ipairs(vim.api.nvim_get_runtime_file("lsp/*.lua", true)) do
  local name = vim.fn.fnamemodify(file, ":t:r")
  local cmd = vim.lsp.config[name] and vim.lsp.config[name].cmd
  if type(cmd) == "table" and installed(cmd[1]) then
    vim.lsp.enable(name)
  end
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("sumi.lsp", { clear = true }),
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))

    -- The server's items in the menu 'autocomplete' opens (through
    -- 'omnifunc'), with <C-y> also adding imports and expanding snippets.
    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, ev.buf)
    end

    -- Formatted on save by servers that can, e.g. rustfmt through rust-analyzer.
    if client:supports_method("textDocument/formatting") then
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("sumi.lsp.format." .. ev.buf, { clear = true }),
        buffer = ev.buf,
        callback = function()
          vim.lsp.buf.format({ bufnr = ev.buf, id = client.id, timeout_ms = 1000 })
        end,
      })
    end
  end,
})
