async = require("async")
moment = require("moment")

Post = require("./post")

Site = module.exports =

  read : (url, callback) ->

    site =
      url : url
      time : moment()

    async.waterfall([
      
      Post.readAll

      (posts, callback) ->

        site.posts = _.sortBy(posts, (post) -> -post.date.valueOf())
        callback(null, site)

    ], callback)
