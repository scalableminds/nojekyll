fs = require("fs")
gm = require("gm")
async = require("async")

module.exports = (app) ->

  resizeImage = (imagePath, imageKey, callback) ->

    options = _.defaults(app.config.images[imageKey],
      upscale: false
      crop: false
      quality: 1
    )

    async.waterfall([

      (callback) -> gm(imagePath).size(callback)

      (size, callback) ->

        if not options.upscale and
        (size.width < options.width or size.height < options.height)
          callback(null, fs.createReadStream(imagePath))

        else 
          if options.crop
            resizer = gm(imagePath)
              .resize(options.width, options.height, "^")
              .gravity("Center")
              .crop(options.width, options.height)
          else
            resizer = gm(imagePath)
              .resize(options.width, options.height)
          

          callback(
            null, 
            resizer
              .quality(Math.floor(options.quality * 100))
              .stream()
          )

    ], callback)
    

  app.imports.imageFile = (path, key) -> path.replace(/\.\w+$/, (ext) -> "-#{key}#{ext}")

  app.use("/images", (req, res, next) ->

    if match = req.path.match(/\/.*-(.+)\.(\w+)/)
      [a, imageKey, ext] = match

      if app.config.images[imageKey]
        originalFilename = "#{app.config.path.root}/#{app.config.path.images}#{req.path.replace("-#{imageKey}","")}"
        fs.exists(originalFilename, (exists) ->
          if exists

            resizeImage(originalFilename, imageKey, (err, stream) ->
              if err
                res.send(500, err.toString())
              else
                res.status(200)
                stream.pipe(res)
            )

          else
            next()
        )
      else
        next()
    else
      next()
  )