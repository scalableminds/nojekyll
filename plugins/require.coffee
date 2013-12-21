requirejs = require("requirejs")
tmp = require("tmp")

module.exports = (app) ->

  config = 
    baseUrl : "#{app.config.path.root}/scripts"
    # optimize : "none"
    paths : 
      "jquery" : "jquery-2.0.3"
      "underscore" : "lodash-2.2.1"
      "bootstrap" : "bootstrap"
      "almond" : "almond-0.2.7"
    shim : 
      "bootstrap" : [ "jquery" ]
    name : "almond"
    wrap : true
        


  app.get("/scripts/:scriptName.js", (req, res) ->

    moduleName = req.params.scriptName

    clonedConfig = _.clone(config)

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
