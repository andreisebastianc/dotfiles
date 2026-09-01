-- Overrides on top of nvim-lspconfig's lsp/ts_ls.lua (which also prefers the
-- project's node_modules/.bin/typescript-language-server and handles
-- monorepo/deno roots). Works with TypeScript 7 (tsgo) too.
return {
	settings = {
		typescript = {
			preferences = {
				importModuleSpecifierPreference = "shortest",
				importModuleSpecifierEnding = "auto",
			},
			suggest = {
				completeFunctionCalls = true,
				includeAutomaticOptionalChainCompletions = true,
			},
			inlayHints = {
				includeInlayParameterNameHints = "literals",
				includeInlayFunctionLikeReturnTypeHints = true,
				includeInlayEnumMemberValueHints = true,
			},
		},
		javascript = {
			preferences = {
				importModuleSpecifierPreference = "shortest",
				importModuleSpecifierEnding = "auto",
			},
			suggest = {
				completeFunctionCalls = true,
			},
			inlayHints = {
				includeInlayParameterNameHints = "literals",
				includeInlayFunctionLikeReturnTypeHints = true,
			},
		},
	},
}
