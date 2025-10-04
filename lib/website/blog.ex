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

  @tags Enum.flat_map(@articles, & &1.tags) |> Enum.uniq() |> Enum.sort()

  @doc """
  Returns all articles.
  """
  def all_articles, do: @articles

  @doc """
  Returns all tags.
  """
  def all_tags, do: @tags

  @doc """
  Returns the most recent articles.
  """
  def recent_articles(count \\ 3), do: Enum.take(all_articles(), count)

  @doc """
  List articles by tag.
  """
  def articles_by_tag(tag) when is_nil(tag), do: @articles

  def articles_by_tag(tag) do
    Enum.filter(@articles, fn article ->
      Enum.any?(article.tags, fn t -> String.downcase(t) == String.downcase(tag) end)
    end)
  end

  @doc """
  Returns an article by its slug.
  """
  def get_article_by_slug(slug) do
    Enum.find(@articles, &(&1.slug == slug))
  end

  @doc """
  Returns recommended articles for a given article.
  """
  def get_recommended_articles(current_article, count) do
    all_articles()
    |> Enum.reject(&(&1.id == current_article.id))
    |> Enum.take_random(count)
  end
end
