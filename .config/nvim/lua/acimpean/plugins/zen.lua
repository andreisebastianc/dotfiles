return {
	"folke/zen-mode.nvim",
	opts = {
		plugins = {
			-- Drives the ZEN_MODE handler in wezterm.lua (bigger font, no tab
			-- bar). Only under WezTerm; other terminals have no equivalent.
			wezterm = {
				enabled = vim.env.TERM_PROGRAM == "WezTerm" or vim.env.WEZTERM_PANE ~= nil,
				font = "+4",
			},
		},
	},
	keys = {
		{
			"<leader>zz",
			function()
				require("zen-mode").toggle({
					window = { width = 90 },
					on_open = function()
						vim.wo.wrap = false
						vim.wo.number = true
						vim.wo.rnu = true
					end,
				})
			end,
			desc = "Zen mode (numbered)",
		},
		{
			"<leader>zZ",
			function()
				require("zen-mode").toggle({
					window = { width = 80 },
					on_open = function()
						vim.wo.wrap = false
						vim.wo.number = false
						vim.wo.rnu = false
						vim.opt.colorcolumn = "0"
					end,
					on_close = function()
						vim.opt.colorcolumn = "80"
					end,
				})
			end,
			desc = "Zen mode (minimal)",
		},
	},
}
