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
    local function read_alias(name)
        local f = io.open(nvm_dir .. "/alias/" .. name, "r")
        if not f then
            return nil
        end
        local value = (f:read("*l") or ""):gsub("%s+", "")
        f:close()
        return value ~= "" and value or nil
    end

    -- The default alias can be a version ("22", "v22.17.1"), another alias
    -- ("lts/*" -> "lts/krypton" -> "v24.x.y"), or "node"/"stable" (newest
    -- installed). Follow alias files until something version-like is left.
    local alias = read_alias("default")
    for _ = 1, 5 do
        local target = alias and not alias:match("^v?%d") and read_alias(alias)
        if not target then
            break
        end
        alias = target
    end

    if alias then
        local prefix = alias:match("^v?(%d[%d.]*)$") or ""
        if prefix ~= "" or alias == "node" or alias == "stable" then
            local matches = vim.fn.glob(nvm_dir .. "/versions/node/v" .. prefix .. "*/bin", false, true)
            -- Newest version last; a plain string sort puts v22.9 after v22.17.
            local function version(path)
                return vim.version.parse(path:match("/v([%d.]+)/bin$") or "") or vim.version.parse("0.0.0")
            end
            table.sort(matches, function(a, b)
                return vim.version.lt(version(a), version(b))
            end)
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

vim.opt.autoindent = true
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
