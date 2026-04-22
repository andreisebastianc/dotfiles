-- Ensure version managers (rbenv, goenv, nvm) are visible to LSP/linters
-- even when nvim isn't launched from a fully-sourced shell (e.g. macOS GUI).
local home = os.getenv("HOME") or ""
local extra_paths = {
    home .. "/.rbenv/shims",
    home .. "/.rbenv/bin",
    home .. "/.goenv/shims",
    home .. "/.goenv/bin",
}

-- NVM doesn't use shims — the bin dir includes the version number.
-- Use NVM_BIN if set, otherwise find the default version's bin dir.
local nvm_bin = os.getenv("NVM_BIN")
if not nvm_bin then
    local nvm_dir = os.getenv("NVM_DIR") or (home .. "/.nvm")
    local alias_file = nvm_dir .. "/alias/default"
    local f = io.open(alias_file, "r")
    if f then
        local alias = f:read("*l"):gsub("%s+", "")
        f:close()
        -- Alias can be a major version ("22") or full ("v22.17.1").
        -- Glob to find the matching installed version.
        local pattern = nvm_dir .. "/versions/node/v" .. alias .. "*/bin"
        local matches = vim.fn.glob(pattern, false, true)
        if #matches > 0 then
            table.sort(matches)
            nvm_bin = matches[#matches]
        end
    end
end
if nvm_bin then
    table.insert(extra_paths, nvm_bin)
end

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

-- Source .nvim.lua in project root for per-project overrides.
-- Neovim only runs trusted files (prompts on first encounter).
vim.opt.exrc = true

vim.g.lazyvim_prettier_needs_config = false
