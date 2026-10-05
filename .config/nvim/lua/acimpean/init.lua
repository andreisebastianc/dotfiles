-- set goes first: it puts rbenv/goenv/nvm on PATH, which plugin specs
-- check with vim.fn.executable() while lazy loads them.
require("acimpean.set")
require("acimpean.lazy")
require("acimpean.remap")
require("acimpean.lsp")
require("acimpean.notes")
require("acimpean.npm_scripts")
