requirejs = require("requirejs")
tmp = require("tmp")

module.exports = (app) ->

  config = _.merge(
    baseUrl : "#{app.config.path.root}/#{app.config.path.scripts}"
    wrap : true
    app.config.scripts
  )
        

  # We're treating all files like AMD modules.
  # We don't optimize over multiple requests.
  app.get("/scripts/:scriptName.js", (req, res) ->

    moduleName = req.params.scriptName

    clonedConfig = _.clone(config)

    # The RequireJS optimizer wants to output a file.
    # So, here is a temp file that it can use.
    tmp.tmpName((err, path) ->

      if err
        res.send(500, err.toString())

      else
        clonedConfig = _.extend(
          {}
          config
          out : path
          include : [ moduleName ]
          insertRequire : [ moduleName ]
        )

        requirejs.optimize(clonedConfig, (response) ->
          res.type("text/javascript")
          res.sendfile(path)
        )

    )
  )
