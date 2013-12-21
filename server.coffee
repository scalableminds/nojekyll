require("coffee-script").register()
GLOBAL._ = require("lodash")

express = require("express")
async = require("async")
fs = require("fs")
path = require("path")
moment = require("moment")
glob = require("glob")
connect = require("connect")


config = require("./config")
Renderer = require("./renderer")
Page = require("./page")
Post = require("./post")
Site = require("./site")

config = _.merge(config, require("#{process.cwd()}/config"))


_.templateSettings.imports.encrypt = (input) -> input.replace(/./g, (a) ->  "&##{a.charCodeAt(0)};")


app = express()

app.imports = _.templateSettings.imports
app.config = config

app.use(connect.logger("tiny"))

app.use((req, res, next) ->

  Site.read(req.path, (err, site) ->
    if err
      res.send(500, err.toString())

    else 
      Post.match(req.path, site, (err, post) ->
        if err
          res.send(500, err.toString())

        else if not post?
          next()

        else
          Renderer.renderPost(post, site, (err, html) -> res.send(html))
      )

  )

)

app.use((req, res, next) ->

  Site.read(req.path, (err, site) ->

    if err
      res.send(500, err.toString())

    else
      Page.match(req.path, site, (err, page) ->
        if err
          res.send(500, err.toString())

        else if not page?
          next()

        else
          Renderer.renderPage(page, site, (err, html) -> res.send(html))
      )
      
  )

)

fs.readdirSync("#{__dirname}/plugins").forEach( (path) ->
  require("#{__dirname}/plugins/#{path}")(app)
)

fs.readdirSync("#{config.path.root}/#{config.path.plugins}").forEach( (path) ->
  require("#{config.path.root}/#{config.path.plugins}/#{path}")(app)
)

app.use(express.static(config.path.root))

app.listen(config.port)