-- npm install -g @ember-tooling/ember-language-server
return {
	cmd = { "ember-language-server", "--stdio" },
	filetypes = { "handlebars", "typescript", "javascript", "typescript.glimmer", "javascript.glimmer" },
	-- Only ember-cli-build.js — with ".git" as a marker this server attached
	-- to every JS/TS file in every git repo, not just Ember projects.
	root_markers = { "ember-cli-build.js" },
	-- Without this, Neovim still starts the server in single-file mode when
	-- no root marker is found — i.e. in every non-Ember project.
	workspace_required = true,
}
