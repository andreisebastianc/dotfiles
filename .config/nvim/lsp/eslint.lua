-- npm i -g vscode-langservers-extracted
return {
	cmd = { "vscode-eslint-language-server", "--stdio" },
	filetypes = {
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
		"vue",
		"svelte",
		"astro",
	},
	root_markers = {
		"eslint.config.js",
		"eslint.config.mjs",
		"eslint.config.cjs",
		".eslintrc",
		".eslintrc.js",
		".eslintrc.cjs",
		".eslintrc.yaml",
		".eslintrc.yml",
		".eslintrc.json",
	},
	on_attach = function(client)
		local root = client.root_dir
		if not root then
			client:stop(true)
			return
		end
		local eslint_configs = {
			"eslint.config.js", "eslint.config.mjs", "eslint.config.cjs",
			".eslintrc", ".eslintrc.js", ".eslintrc.cjs",
			".eslintrc.yaml", ".eslintrc.yml", ".eslintrc.json",
		}
		for _, name in ipairs(eslint_configs) do
			if vim.uv.fs_stat(root .. "/" .. name) then
				return
			end
		end
		vim.notify("ESLint: no config found, stopping for this project", vim.log.levels.INFO)
		client:stop(true)
	end,
}
