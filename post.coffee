async = require("async")
fs = require("fs")
moment = require("moment")

config = require("./config")
Page = require("./page")


Post = module.exports =    

  read : (filename, callback) ->

    [a, date, slug] = filename.match(config.patterns.post)

    post =
      date : moment(date)
      slug : slug
      filename : filename

    async.waterfall([

      (callback) -> Page.read("#{config.path.root}/#{config.path.posts}#{filename}", callback)

      (page, callback) ->

        _.extend(post, page)

        if (excerptLength = post.content.indexOf(config.excerpt_seperator)) >= 0
          post.excerpt = post.content.substring(0, excerptLength)
        else
          post.excerpt = post.content
          
        post.url = config.url.post(post)

        callback(null, post)

    ], callback)


  readAll : (callback) ->

    async.waterfall([

      (callback) -> fs.readdir("#{config.path.root}/#{config.path.posts}", callback)

      (postFilenames, callback) ->
      
        postFilenames = postFilenames.filter((a) -> config.patterns.post.test(a))
        async.map(postFilenames, Post.read, callback)

    ], callback)


  match : (url, site, callback) ->

    callback(null, _.detect(site.posts, url : url))

