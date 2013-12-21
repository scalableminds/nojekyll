module.exports = (app) ->
  # Simple email encryption through Unicode notation
	app.imports.encrypt = (input) -> input.replace(/./g, (a) ->  "&##{a.charCodeAt(0)};")