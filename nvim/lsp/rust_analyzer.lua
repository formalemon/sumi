-- Rust. Needs `rustup component add rust-analyzer`.
return {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  -- Cargo.lock sits at a workspace's root, so all its crates share one server.
  root_markers = { "Cargo.lock", "Cargo.toml", ".git" },
  settings = {
    ["rust-analyzer"] = {
      check = { command = "clippy" },
    },
  },
}
