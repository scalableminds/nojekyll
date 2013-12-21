module.exports = (app) ->

  # Short hand for making gallery lists.
  app.imports.gallery = (post, prefix, items...) ->

    items = items.map( (item) -> "#{prefix}#{item}" )

    _.template(
      """
        <ul class="post-gallery">
        <% items.forEach(function (img, i) { %>
          <li>
            <a href="<%= post.url %>#gallery-<%= i %>">
              <img src="<%= imageFile(img, "thumbnail") %>">
            </a>
            <a href="<%= imageFile(img, "gallery") %>" class="hide"></a>
          </li>
        <% }); %>
        </ul>
      """
      { post, items }
    )