return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		lazy = false,
		config = function()
			require("catppuccin").setup({
				flavour = "mocha",
				-- Let the terminal background (ghostty/tmux) show through.
				transparent_background = true,
				integrations = {
					diffview = true,
					harpoon = true,
					lsp_trouble = true,
					mason = true,
					which_key = true,
				},
			})
			vim.cmd.colorscheme("catppuccin")
		end,
	},
	-- Kept as an alternative; lazy.nvim loads it on `:colorscheme rose-pine`.
	{ "rose-pine/neovim", name = "rose-pine", lazy = true },
}
