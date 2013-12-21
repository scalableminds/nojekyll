require("coffee-script").register()
GLOBAL._ = require("lodash")

# npm modules
express = require("express")
async = require("async")
fs = require("fs")
path = require("path")
moment = require("moment")
glob = require("glob")
connect = require("connect")

# local modules
config = require("./config")
Renderer = require("./renderer")
Page = require("./page")
Post = require("./post")
Site = require("./site")

# merge user config with default config
if fs.existsSync("#{process.cwd()}/config.coffee") or fs.existsSync("#{process.cwd()}/config.js")
  config = _.merge(config, require("#{process.cwd()}/config"))

# Setup Express
app = express()


# Hooks for plugins
app.imports = _.templateSettings.imports
app.config = config

# Logging
app.use(connect.logger("tiny"))


# Serving posts
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

# Serving pages
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

# Include bundled plugins
if fs.existsSync("#{__dirname}/plugins")
  fs.readdirSync("#{__dirname}/plugins").forEach( (path) ->
    require("#{__dirname}/plugins/#{path}")(app)
  )

# Include user plugins
if fs.existsSync("#{config.path.root}/#{config.path.plugins}")
  fs.readdirSync("#{config.path.root}/#{config.path.plugins}").forEach( (path) ->
    require("#{config.path.root}/#{config.path.plugins}/#{path}")(app)
  )

# Serve all the other files
app.use(express.static(config.path.root))

# Here we go
app.listen(config.port)
