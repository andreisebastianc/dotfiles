-- Installed via Mason (ruby-lsp). Pulls in rubocop diagnostics automatically
-- if your project has rubocop in the Gemfile.
return {
	cmd = { "ruby-lsp" },
	filetypes = { "ruby", "eruby" },
	root_markers = { "Gemfile", ".git" },
	init_options = {
		formatter = "auto",
	},
}
