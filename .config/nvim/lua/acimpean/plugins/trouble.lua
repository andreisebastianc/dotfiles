return {
	"folke/trouble.nvim",
	opts = {
		icons = {
			indent = {
				middle = " ",
				last = " ",
				top = " ",
				ws = "│  ",
			},
		},
	},
	cmd = "Trouble",
	keys = {
		{
			"<leader>xx",
			function()
				-- Show inline diagnostics before opening the panel
				vim.diagnostic.config({
					underline = { severity = vim.diagnostic.severity.ERROR },
					virtual_lines = { current_line = true },
					signs = true,
				})
				vim.cmd("Trouble diagnostics toggle")
			end,
			desc = "Diagnostics (Trouble)",
		},
		{
			"<leader>xX",
			function()
				vim.diagnostic.config({
					underline = { severity = vim.diagnostic.severity.ERROR },
					virtual_lines = { current_line = true },
					signs = true,
				})
				vim.cmd("Trouble diagnostics toggle filter.buf=0")
			end,
			desc = "Buffer Diagnostics (Trouble)",
		},
		{
			"<leader>cs",
			"<cmd>Trouble symbols toggle focus=false<cr>",
			desc = "Symbols (Trouble)",
		},
		{
			"<leader>cl",
			"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
			desc = "LSP Definitions / references / ... (Trouble)",
		},
		{
			"<leader>xL",
			"<cmd>Trouble loclist toggle<cr>",
			desc = "Location List (Trouble)",
		},
		{
			"<leader>xQ",
			"<cmd>Trouble qflist toggle<cr>",
			desc = "Quickfix List (Trouble)",
		},
		{
			"<leader>xt",
			"<cmd>Trouble todo toggle<cr>",
			desc = "TODOs (Trouble)",
		},
	},
}
