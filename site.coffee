async = require("async")
moment = require("moment")

Post = require("./post")

Site = module.exports =

  read : (url, callback) ->

    site =
      url : url
      time : moment()

    async.waterfall([
      
      # Get all posts
      Post.readAll

      (posts, callback) ->

        # Sort by post date DESC
        site.posts = _.sortBy(posts, (post) -> -post.date.valueOf())
        
        callback(null, site)

    ], callback)
