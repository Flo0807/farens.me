defmodule Website.Blog do
  @moduledoc """
  The blog context.
  """
  use NimblePublisher,
    build: Website.Blog.Article,
    from: Application.app_dir(:website, "priv/resources/articles/**/*.md"),
    as: :articles,
    html_converter: Website.MarkdownConverter

  @articles Enum.filter(@articles, & &1.published) |> Enum.sort_by(& &1.date, {:desc, Date})

  @doc """
  Returns all articles.
  """
  def all_articles, do: @articles

  @doc """
  Returns the most recent articles.
  """
  def recent_articles(count \\ 3), do: Enum.take(all_articles(), count)

  @doc """
  Returns an article by its slug.
  """
  def get_article_by_slug(slug) do
    Enum.find(@articles, &(&1.slug == slug))
  end

  @doc """
  Returns the og image path for an article.
  """
  def get_og_image_path(article, conn) do
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
        Phoenix.VerifiedRoutes.unverified_url(conn, file)

      false ->
        nil
    end
  end
end
