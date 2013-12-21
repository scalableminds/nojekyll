async = require("async")
fs = require("fs")
yaml = require("yamljs")
glob = require("glob")


config = require("./config")

Page = module.exports = 

  read : (filename, callback) ->

    page =
      filename : filename

    async.waterfall([

      (callback) -> fs.readFile(filename, "utf8", callback)

      (fileData, callback) ->
        _.extend(page, Page.readFrontMatter(fileData))
        callback(null, page)
        
    ], callback)

  
  readFrontMatter : (fileData) ->

    [a, frontMatter, content] = fileData.match(config.patterns.splitFrontMatter)
    
    page =
      content : content

    if frontMatter
      _.extend(page, yaml.parse(frontMatter))

    page


  match : (url, site, callback) ->

    url = url.replace(/\/$/, "")
    async.waterfall([

      (callback) ->
        glob("#{config.path.root}#{config.path.pages}#{url}{/,}{index,}.html", callback)

      (files, callback) -> 
        if files.length == 0
          callback(null, null)

        else
          Page.read(files[0], callback)
        
    ], callback)