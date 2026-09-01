# nvim

Shared across several machines (Linux + macOS). Language servers, formatters
and linters are gated on the toolchain that exists on each box, so nothing
errors when e.g. Go isn't installed.

## Dependencies (install per machine)

* `ripgrep` — telescope, `<leader>pn`
* a C compiler, `curl`, `tar` — nvim-treesitter (main) builds parsers locally
  (the `tree-sitter` CLI itself comes from Mason)
* `node` — Mason installs the JS/TS servers, prettier and eslint_d with npm
* Ruby: `gem install ruby-lsp rubocop` in the project's Ruby (not Mason-managed
  on purpose — must match the project)
* Go / Zig: install the toolchain, Mason handles gopls/goimports/zls

First start: `:Lazy sync`, then `:MasonToolsInstall`, then restart so the
executable checks pick up the new binaries.

Run `:checkhealth` after that; `:ConformInfo` shows which formatter will run
for the current buffer and why one is skipped.
