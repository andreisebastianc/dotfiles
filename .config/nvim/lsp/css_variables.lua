-- npm i -g css-variables-language-server
return {
	cmd = { "css-variables-language-server", "--stdio" },
	filetypes = { "css" },
	root_markers = { "package.json", ".git" },
	settings = {
		cssVariables = {
			lookupFiles = { "**/*.css" },
			blacklistFolders = {
				"**/.cache",
				"**/.DS_Store",
				"**/.git",
				"**/.hg",
				"**/.next",
				"**/bower_components",
				"**/CVS",
				"**/dist",
				"**/node_modules",
				"**/tests",
				"**/tmp",
			},
		},
	},
}
