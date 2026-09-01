-- Overrides on top of nvim-lspconfig's lsp/gopls.lua.
return {
	settings = {
		gopls = {
			analyses = {
				unusedparams = true,
				shadow = true,
			},
			staticcheck = true,
		},
	},
}
