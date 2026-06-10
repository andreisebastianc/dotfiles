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
				disable = { "markdown" },
				additional_vim_regex_highlighting = { "markdown" },
			},
			-- Treesitter's indent module is experimental and, on the archived
			-- master branch, is incompatible with Neovim 0.12: its query
			-- predicates call node:type() on what is now a list of nodes,
			-- so nvim_treesitter#indent() throws and indentexpr falls back to
			-- column 0 while typing. Disable it and rely on Neovim's built-in
			-- filetype indent (indent/typescript.vim, javascript.vim, …),
			-- which handles incomplete code gracefully.
			indent = { enable = false },
		})
	end,
}
