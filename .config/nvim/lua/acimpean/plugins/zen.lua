return {
	"folke/zen-mode.nvim",
	opts = {},
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
				ColorMyPencils()
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
				ColorMyPencils()
			end,
			desc = "Zen mode (minimal)",
		},
	},
}
