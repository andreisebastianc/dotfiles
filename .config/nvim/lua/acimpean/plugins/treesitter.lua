return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"lua",
				"vim",
				"vimdoc",
				"dockerfile",
				"typescript",
				"tsx",
				"glimmer_typescript",
				"glimmer_javascript",
				"javascript",
				"html",
				"css",
				"markdown",
				"markdown_inline",
				"ruby",
				"embedded_template",
				"go",
				"gomod",
				"gosum",
				"zig",
			},
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},
			indent = { enable = true },
		})
	end,
}
