defimpl SEO.OpenGraph.Build, for: Website.Blog.Article do
  use WebsiteWeb, :verified_routes

  def build(article, _conn) do
    og_img =
      SEO.OpenGraph.Image.build(%{
        url: "https://og-image.farens.me/image?text=#{URI.encode(article.title)}",
        alt: article.title
      })

    SEO.OpenGraph.build(
      detail:
        SEO.OpenGraph.Article.build(
          published_time: Date.to_iso8601(article.date),
          author: "Florian Arens",
          section: "Software Development",
          tag: article.tags
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

  def build(article, _conn) do
    SEO.Twitter.build(
      description: article.description,
      title: article.title,
      image: "https://og-image.farens.me/image?text=#{URI.encode(article.title)}"
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

defimpl SEO.JSONLD.Build, for: Website.Blog.Article do
  use WebsiteWeb, :verified_routes

  def build(article, conn) do
    article_url = url(conn, ~p"/blog/#{article.slug}")

    [
      SEO.JSONLD.BlogPosting.build(%{
        headline: article.title,
        description: article.description,
        date_published: article.date,
        author:
          SEO.JSONLD.Person.build(%{
            name: "Florian Arens",
            url: url(conn, ~p"/about")
          }),
        image: "https://og-image.farens.me/image?text=#{URI.encode(article.title)}",
        keywords: article.tags,
        main_entity_of_page: article_url
      }),
      SEO.JSONLD.Breadcrumbs.build([
        %{name: "Blog", item: url(conn, ~p"/blog")},
        %{name: article.title, item: article_url}
      ])
    ]
  end
end
