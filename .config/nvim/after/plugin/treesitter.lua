require("nvim-treesitter.configs").setup {
	ensure_installed = { 
		"lua", 
		"dockerfile",
		"typescript", 
		"glimmer_typescript", 
		"glimmer_javascript", 
		"javascript", 
		"html", 
		"css" 
	}, -- specify languages
	highlight = {
		enable = true, -- enable syntax highlighting
		additional_vim_regex_highlighting = false,
	},
}
