module.exports =

  url : 
    # How would you like your blog post urls?
    post : (post) ->
      return "/blog/#{post.category}/#{post.date.format("YYYY")}/#{post.date.format("MM")}/#{post.date.format("DD")}/#{post.slug}"

  # You may change any of these paths. They do support `glob` syntax.
  path :
    # This is the root of all source files
    root : "#{process.cwd()}/src"

    # Where do you have your template includes?
    includes : "{includes,layouts}"

    # Where did you put your layouts?
    layouts : "layouts"

    # Do you have a root for your pages? Can be the root directory.
    pages : ""

    # Where are your posts? Needs to be a separate directory.
    posts : "posts/"

    # Where do you store images?
    images : "images/"
    
    # Where do you store scripts?
    scripts : "scripts/"

    # Where are your styles?
    styles : "styles/"

    # You can have custom plugins aswell.
    plugins : "plugins"

    # How can we find layouts? We need a unique suffix.
    layoutSuffix : ".layout.html"


  patterns :
    # Pattern for finding template include tags.
    include : /<%=\s*include\s*\("(.*?)"\)\s*%>/g

    # Pattern for finding content gaps in layouts.
    content : /<%=\s*content\s*%>/g

    # Pattern for post filename.
    post : /^(\d{4}\-\d{2}\-\d{2})\-(.*)\.md$/

    # Pattern to split front-matter from the rest.
    splitFrontMatter : /^\s*(?:---\n([^]*)---\n)?([^]*)$/m

  # Excerpts will be cut off before the first occurence of this token.
  excerpt_seperator : "<!-- break -->"

  # Your image presets
  images : {}

  # On which port should the server listen?
  port : 3000