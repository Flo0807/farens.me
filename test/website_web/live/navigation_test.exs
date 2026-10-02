defmodule WebsiteWeb.NavigationTest do
  use WebsiteWeb.ConnCase, async: true

  alias Website.Blog

  test "an article can be opened from home and returned to the blog" do
    article = Blog.all_articles() |> hd()

    build_conn()
    |> visit("/")
    |> click_link(article.title)
    |> assert_path("/blog/#{article.slug}")
    |> assert_has("h1", text: article.title)
    |> click_link("Back to articles")
    |> assert_path("/blog")
  end

  test "topic filters update the article list and can be cleared" do
    tag = Blog.all_tags() |> hd()
    normalized_tag = String.downcase(tag)
    matching_articles = Blog.articles_by_tag(normalized_tag)

    session =
      build_conn()
      |> visit("/blog")
      |> click_button(tag)
      |> assert_path("/blog/tag/#{normalized_tag}")
      |> assert_has("main button[aria-pressed=true]", text: tag)

    session =
      Enum.reduce(matching_articles, session, fn article, session ->
        assert_has(session, "#articles a", text: article.title)
      end)

    session
    |> click_button(tag)
    |> assert_path("/blog")
    |> refute_has("main button[aria-pressed=true]")
    |> assert_has("#articles article", count: length(Blog.all_articles()))
  end
end
