defmodule Website.Blog do
  @doc """
  The blog context.
  """
  use NimblePublisher,
    build: Website.Blog.Article,
    from: Application.app_dir(:website, "priv/resources/articles/**/*.md"),
    as: :articles,
    html_converter: Website.MarkdownConverter

  @articles Enum.sort_by(@articles, & &1.date, {:desc, Date})

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
end
