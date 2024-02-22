defimpl SEO.OpenGraph.Build, for: Website.Blog.Article do
  use WebsiteWeb, :verified_routes

  def build(article, conn) do
    og_img =
      case Website.Blog.get_og_image_path(article, conn) do
        nil ->
          SEO.OpenGraph.Image.build(%{
            url: url(~p"/images/og/og-image.jpg"),
            alt: article.title
          })

        url ->
          SEO.OpenGraph.Image.build(
            url: url,
            alt: article.title
          )
      end

    SEO.OpenGraph.build(
      detail:
        SEO.OpenGraph.Article.build(
          published_time: Date.to_iso8601(article.date),
          author: "Florian Arens",
          section: "Software Development"
        ),
      title: article.title,
      description: article.description,
      image: og_img
    )
  end
end

defimpl SEO.Site.Build, for: Website.Blog.Article do
  def build(article, _conn) do
    SEO.Site.build(
      title: article.title,
      description: article.description
    )
  end
end

defimpl SEO.Twitter.Build, for: Website.Blog.Article do
  use WebsiteWeb, :verified_routes

  def build(article, conn) do
    img_url =
      case Website.Blog.get_og_image_path(article, conn) do
        nil ->
          url(~p"/images/og/og-image.jpg")

        url ->
          url
      end

    SEO.Twitter.build(
      description: article.description,
      title: article.title,
      image: img_url
    )
  end
end

defimpl SEO.Unfurl.Build, for: Website.Blog.Article do
  def build(article, _conn) do
    SEO.Unfurl.build(
      label1: "Reading Time",
      data1: "#{article.read_minutes} minutes",
      label2: "Published",
      data2: Date.to_iso8601(article.date)
    )
  end
end

defimpl SEO.Breadcrumb.Build, for: Website.Blog.Article do
  use WebsiteWeb, :verified_routes

  def build(article, _conn) do
    SEO.Breadcrumb.List.build([
      %{name: "Blog", item: url(~p"/blog")},
      %{name: article.title, item: url(~p"/blog/#{article.slug}")}
    ])
  end
end
