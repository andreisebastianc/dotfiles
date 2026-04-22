-- Diagnostic display styles
local diag_shown = {
	severity_sort = true,
	underline = { severity = vim.diagnostic.severity.ERROR },
	virtual_text = false,
	virtual_lines = { current_line = true },
	signs = true,
	float = { border = "rounded", source = "if_many" },
}

local diag_hidden = {
	severity_sort = true,
	underline = false,
	virtual_text = false,
	virtual_lines = false,
	signs = false,
	float = { border = "rounded", source = "if_many" },
}

-- Start with diagnostics hidden — they appear after first save
vim.diagnostic.config(diag_hidden)

local function show_diagnostics()
	vim.diagnostic.config(diag_shown)
end

local function hide_diagnostics()
	vim.diagnostic.config(diag_hidden)
end

-- Show diagnostics after save
vim.api.nvim_create_autocmd("BufWritePost", {
	callback = show_diagnostics,
})

-- Hide while editing so they don't flicker
vim.api.nvim_create_autocmd("InsertEnter", {
	callback = hide_diagnostics,
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

-- Enable servers (config comes from lsp/<name>.lua files in runtimepath)
vim.lsp.enable({ "ember", "ts_ls", "css_variables", "eslint", "ruby_lsp", "gopls", "zls" })

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
