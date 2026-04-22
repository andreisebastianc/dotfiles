-- Ensure version managers (rbenv, goenv, etc.) are visible to LSP/linters
-- even when nvim isn't launched from a fully-sourced shell.
local home = os.getenv("HOME") or ""
local extra_paths = {
    home .. "/.rbenv/shims",
    home .. "/.rbenv/bin",
    home .. "/.goenv/shims",
    home .. "/.goenv/bin",
}
for _, p in ipairs(extra_paths) do
    if vim.fn.isdirectory(p) == 1 and not vim.env.PATH:find(p, 1, true) then
        vim.env.PATH = p .. ":" .. vim.env.PATH
    end
end

vim.opt.guicursor = ""

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true
vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.colorcolumn = "80"

vim.g.lazyvim_prettier_needs_config = false
