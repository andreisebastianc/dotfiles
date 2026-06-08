return {
	{
		"mason-org/mason.nvim",
		opts = {
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		},
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "mason-org/mason.nvim" },
		event = "VeryLazy",
		opts = {
			ensure_installed = {
				"ember-language-server",
				"typescript-language-server",
				"css-variables-language-server",
				"ruby-lsp",
				"gopls",
				"zls",

				"prettier",
				"stylua",
				"rubocop",
				"goimports",

				"eslint_d",
				"pylint",
				"golangci-lint",
			},
			run_on_start = true,
			auto_update = false,
			start_delay = 3000,
		},
	},
}
