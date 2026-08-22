defmodule Website.Blog.ArticleImplTest do
  use WebsiteWeb.ConnCase, async: true

  alias Website.Blog

  test "builds blog posting and breadcrumb structured data" do
    article = Blog.get_article_by_slug("hello-world")
    conn = build_conn() |> put_private(:phoenix_endpoint, WebsiteWeb.Endpoint)
    base_url = WebsiteWeb.Endpoint.url()

    [blog_posting, breadcrumbs] = SEO.JSONLD.Build.build(article, conn)

    assert blog_posting["@type"] == "BlogPosting"
    assert blog_posting["headline"] == article.title
    assert blog_posting["datePublished"] == Date.to_iso8601(article.date)
    assert blog_posting["keywords"] == article.tags
    assert blog_posting["mainEntityOfPage"] == "#{base_url}/blog/hello-world"

    assert blog_posting["author"] == %{
             "@type" => "Person",
             "name" => "Florian Arens",
             "url" => "#{base_url}/about"
           }

    assert breadcrumbs["@type"] == "BreadcrumbList"

    assert Enum.map(breadcrumbs["itemListElement"], & &1["name"]) == [
             "Blog",
             article.title
           ]
  end

  test "renders structured data in the article page" do
    document =
      build_conn()
      |> get("/blog/hello-world")
      |> html_response(200)
      |> LazyHTML.from_fragment()

    structured_data =
      document
      |> LazyHTML.filter(~s(script[type="application/ld+json"]))
      |> LazyHTML.text()
      |> Jason.decode!()

    assert Enum.map(structured_data, & &1["@type"]) == ["BlogPosting", "BreadcrumbList"]
    assert Enum.all?(structured_data, &(&1["@context"] == "https://schema.org"))
  end
end
