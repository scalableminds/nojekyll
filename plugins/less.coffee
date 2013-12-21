less = require("less")
fs = require("fs")

module.exports = (app) ->


  app.use("/styles", (req, res, next) ->

    # Is it actually a css file? Could also be a font.
    if /\.css/.test(req.path)

      lessFilename = req.path.replace(/\.css$/, ".less")

      # Find original less file.
      fs.readFile("#{app.config.path.root}/styles#{lessFilename}", "utf8", (err, fileData) ->

        if err and err.code == "ENOENT"
          next()

        else if err
          res.send(500, err.toString())

        else
          lessParser = new (less.Parser)(
            paths: ["#{app.config.path.root}/styles"],
            filename: "style.less"
          )
          
          lessParser.parse(fileData, (err, tree) ->
            if err
              res.send(500, err.toString())

            else
              res.type("css").send(tree.toCSS())
          )
      )

    else
      next()

  )