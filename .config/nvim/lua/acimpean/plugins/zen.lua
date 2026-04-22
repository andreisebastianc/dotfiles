return {
	"folke/zen-mode.nvim",
	keys = {
		{
			"<leader>zz",
			function()
				local zen = require("zen-mode")
				zen.setup({ window = { width = 90, options = {} } })
				zen.toggle()
				vim.wo.wrap = false
				vim.wo.number = true
				vim.wo.rnu = true
				ColorMyPencils()
			end,
			desc = "Zen mode (numbered)",
		},
		{
			"<leader>zZ",
			function()
				local zen = require("zen-mode")
				zen.setup({ window = { width = 80, options = {} } })
				zen.toggle()
				vim.wo.wrap = false
				vim.wo.number = false
				vim.wo.rnu = false
				vim.opt.colorcolumn = "0"
				ColorMyPencils()
			end,
			desc = "Zen mode (minimal)",
		},
	},
}
