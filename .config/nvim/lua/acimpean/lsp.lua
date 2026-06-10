-- Diagnostic display styles live in acimpean.diagnostics (shared with
-- trouble.nvim). Diagnostics are visible whenever you're not actively
-- typing: shown on open, save, and after leaving insert; hidden while in
-- insert mode to avoid flicker.
local diagnostics = require("acimpean.diagnostics")
diagnostics.show()

vim.api.nvim_create_autocmd("InsertEnter", {
	callback = diagnostics.hide,
})

vim.api.nvim_create_autocmd("InsertLeave", {
	callback = diagnostics.show,
})

-- Completion options for built-in LSP completion
vim.opt.completeopt = { "menu", "menuone", "noselect", "popup", "fuzzy" }

-- Buffer-local keymaps + per-client features on LspAttach
vim.api.nvim_create_autocmd("LspAttach", {
	desc = "LSP actions",
	callback = function(event)
		local bufnr = event.buf
		local client = vim.lsp.get_client_by_id(event.data.client_id)

		local function map(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
		end

		map("n", "K", vim.lsp.buf.hover, "LSP hover")
		map("n", "gd", vim.lsp.buf.definition, "LSP definition")
		map("n", "gD", vim.lsp.buf.declaration, "LSP declaration")
		map("n", "gi", vim.lsp.buf.implementation, "LSP implementation")
		map("n", "go", vim.lsp.buf.type_definition, "LSP type definition")
		map("n", "gr", vim.lsp.buf.references, "LSP references")
		map("n", "gs", vim.lsp.buf.signature_help, "LSP signature help")
		map("n", "<F2>", vim.lsp.buf.rename, "LSP rename")
		map({ "n", "x" }, "<F3>", function() vim.lsp.buf.format({ async = true }) end, "LSP format")
		map("n", "<F4>", vim.lsp.buf.code_action, "LSP code action")

		if client and client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
		end

		if client and client:supports_method("textDocument/inlayHint") then
			vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
		end
	end,
})

-- Enable servers (config comes from lsp/<name>.lua files in runtimepath).
-- Each server is enabled only if its binary exists on this machine, so a
-- missing toolchain (e.g. no Ruby/Go on a given box) doesn't produce
-- "failed to spawn" errors when opening files. Mason's bin dir is already
-- on PATH at this point (mason.nvim loads during lazy.setup).
local servers = {
	ember = "ember-language-server",
	ts_ls = "typescript-language-server",
	css_variables = "css-variables-language-server",
	ruby_lsp = "ruby-lsp",
	gopls = "gopls",
	zls = "zls",
}

for name, bin in pairs(servers) do
	if vim.fn.executable(bin) == 1 then
		vim.lsp.enable(name)
	end
end

-- Toggle LSP for the current buffer
local lsp_buffers_stopped = {}

local function stop_lsp_for_buffer(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local clients = vim.lsp.get_clients({ bufnr = bufnr })
	local names = {}
	for _, c in ipairs(clients) do
		vim.lsp.buf_detach_client(bufnr, c.id)
		table.insert(names, c.name)
	end
	lsp_buffers_stopped[bufnr] = names
	vim.diagnostic.enable(false, { bufnr = bufnr })
	if #names > 0 then
		vim.notify("LSP stopped for buffer: " .. table.concat(names, ", "), vim.log.levels.INFO)
	else
		vim.notify("No LSP clients were attached", vim.log.levels.WARN)
	end
end

local function start_lsp_for_buffer(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	vim.diagnostic.enable(true, { bufnr = bufnr })
	local ft = vim.bo[bufnr].filetype
	vim.api.nvim_exec_autocmds("FileType", { buffer = bufnr, modeline = false })
	lsp_buffers_stopped[bufnr] = nil
	vim.notify("LSP restarted for buffer (filetype: " .. ft .. ")", vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("LspStop", function() stop_lsp_for_buffer() end,
	{ desc = "Detach all LSP clients from current buffer" })
vim.api.nvim_create_user_command("LspStart", function() start_lsp_for_buffer() end,
	{ desc = "Re-attach LSP clients to current buffer" })
vim.api.nvim_create_user_command("LspToggle", function()
	local bufnr = vim.api.nvim_get_current_buf()
	if lsp_buffers_stopped[bufnr] then
		start_lsp_for_buffer(bufnr)
	else
		stop_lsp_for_buffer(bufnr)
	end
end, { desc = "Toggle LSP for current buffer" })

vim.keymap.set("n", "<leader>tl", "<cmd>LspToggle<cr>", { desc = "Toggle LSP (buffer)" })

vim.api.nvim_create_user_command("DiagToggle", function()
	local bufnr = vim.api.nvim_get_current_buf()
	if vim.diagnostic.is_enabled({ bufnr = bufnr }) then
		vim.diagnostic.enable(false, { bufnr = bufnr })
		vim.notify("Diagnostics hidden (buffer)", vim.log.levels.INFO)
	else
		vim.diagnostic.enable(true, { bufnr = bufnr })
		vim.notify("Diagnostics shown (buffer)", vim.log.levels.INFO)
	end
end, { desc = "Toggle diagnostic display for current buffer" })

vim.keymap.set("n", "<leader>td", "<cmd>DiagToggle<cr>", { desc = "Toggle diagnostics (buffer)" })

vim.api.nvim_create_user_command("LspLog", function()
	vim.cmd("edit " .. vim.lsp.log.get_filename())
end, { desc = "Open LSP log file" })
