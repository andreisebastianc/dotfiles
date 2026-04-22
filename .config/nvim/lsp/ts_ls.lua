-- npm install -g typescript typescript-language-server
-- Works with TypeScript 7 (tsgo) — ts_ls wraps the compiler regardless of
-- whether it's the JS or Go implementation.
return {
	cmd = { "typescript-language-server", "--stdio" },
	filetypes = {
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
	},
	root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
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
