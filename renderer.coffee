fs = require("fs")
async = require("async")
marked = require("marked")
glob = require("glob")
highlight = require("highlight.js").highlight


config = require("./config")
Page = require("./page")

markedRenderer = new (marked.Renderer)()
markedRenderer.code = (code, lang) ->
  if lang
    """
    <pre><code class="#{lang}">#{highlight(lang, code).value}</code></pre>
    """
  else
    """
    <pre><code>#{code}</code></pre>
    """
  

marked.setOptions(
  smartypants : true
  renderer : markedRenderer
)


Renderer = module.exports =

  loadLayout : (layoutName, callback) ->

    glob("#{config.path.root}/#{config.path.layouts}/#{layoutName}#{config.path.layoutSuffix}", (err, files) ->

      if err or files.length == 0
        callback(err ? new Error("No file found."))

      else
        fs.readFile(files[0], "utf8", callback)

    )



  loadInclude : (includeName, callback) ->

    glob("#{config.path.root}/#{config.path.includes}/#{includeName}", (err, files) ->

      if err or files.length == 0
        callback(err ? new Error("No file found."))

      else
        fs.readFile(files[0], "utf8", callback)

    )


  resolveLayouts : (post, callback) ->

    # walk up the layout tree
    if post.layout

      async.waterfall([

        (callback) -> Renderer.loadLayout(post.layout, callback)
        
        (layoutData, callback) -> 
          Renderer.resolveLayouts(Page.readFrontMatter(layoutData), callback)

        (layout, callback) ->
          callback(null, layout.replace(config.patterns.content, post.content))

      ], callback)

    else
      callback(null, post.content)



  resolveIncludes : (content, callback) ->

    async.whilst(

      # run while there is still an include tag
      -> config.patterns.include.test(content)

      (callback) ->

        # fetch all includes in content
        includes = []
        content = content.replace(config.patterns.include, (match, includeName) ->
          includes.push(includeName)
          match
        )
        
        async.waterfall([

          # load includes
          (callback) ->
            async.map(
              includes
              (includeName, callback) -> 
                Renderer.loadInclude(includeName, callback)
              callback
            )

          # replace includes in content
          (includesFileData, callback) ->

            includes = _.zipObject(includes, includesFileData)
            content = content.replace(config.patterns.include, (match, includeName) ->
              includes[includeName]
            )
            callback()
            
        ], callback)

      # all done, now
      (err) -> callback(err, content)
    )

  renderSitePosts : (site, callback) ->

    callback(
      null
      site.posts.map( (post) ->
        post.content = marked(_.template(post.content, { post, site }))
        post.excerpt = marked(_.template(post.excerpt, { post, site }))
        post
      )
    )


  renderPost : (post, site, callback) ->

    Renderer.renderPage(post, site, callback)


  renderPage : (page, site, callback) ->

    async.waterfall([

      (callback) -> Renderer.renderSitePosts(site, callback)

      (posts, callback) -> Renderer.resolveLayouts(page, callback)

      (content, callback) -> Renderer.resolveIncludes(content, callback)

      (content, callback) ->
        callback(null, _.template(content, { page, site }))

    ], callback)

