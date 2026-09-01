-- Overrides on top of nvim-lspconfig's lsp/ember.lua.
return {
	-- Only ember-cli-build.js — with ".git" as a marker (lspconfig's default)
	-- this server attached to every JS/TS file in every git repo.
	root_markers = { "ember-cli-build.js" },
	-- Without this, Neovim still starts the server in single-file mode when
	-- no root marker is found — i.e. in every non-Ember project.
	workspace_required = true,
}
