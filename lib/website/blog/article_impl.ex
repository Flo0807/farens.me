defimpl SEO.OpenGraph.Build, for: Website.Blog.Article do
  use WebsiteWeb, :verified_routes

  def build(article, conn) do
    SEO.OpenGraph.build(
      detail:
        SEO.OpenGraph.Article.build(
          published_time: Date.to_iso8601(article.date),
          author: "Florian Arens",
          section: "Software Development"
        ),
      title: article.title,
      description: article.description,
      image: image(article, conn)
    )
  end

  defp image(article, conn) do
    [year, month, day] =
      Calendar.strftime(article.date, "%Y-%m-%d")
      |> String.split("-", parts: 3)

    file = "/images/og/blog/#{year}/#{month}-#{day}-#{article.id}.jpg"

    exists? =
      [Application.app_dir(:website), "/priv/static", file]
      |> Path.join()
      |> File.exists?()

    case exists? do
      true ->
        url = Phoenix.VerifiedRoutes.unverified_url(conn, file)

        SEO.OpenGraph.Image.build(
          url: url,
          alt: article.title
        )

      false ->
        %{}
    end
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
      image: url(~p"/images/og/og-image.jpg")
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
