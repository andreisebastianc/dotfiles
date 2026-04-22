-- npm install -g @ember-tooling/ember-language-server
return {
	cmd = { "ember-language-server", "--stdio" },
	filetypes = { "handlebars", "typescript", "javascript", "typescript.glimmer", "javascript.glimmer" },
	root_markers = { ".git", "ember-cli-build.js" },
}
