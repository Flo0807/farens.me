defmodule Website.Blog.Search do
  @moduledoc """
  Full-text search across blog articles.
  """

  alias Website.Blog

  @max_results 10
  @snippet_length 160

  @doc """
  Searches articles by query string across title, description, tags, and body.
  Returns a list of maps with `:article`, `:match_field`, and `:snippet` keys,
  ranked by match relevance (title > description > tags > body).
  """
  def search(query) when is_binary(query) do
    query = String.trim(query)

    if String.length(query) < 2 do
      []
    else
      query_down = String.downcase(query)

      Blog.all_articles()
      |> Enum.flat_map(&find_matches(&1, query_down))
      |> Enum.sort_by(fn result -> field_priority(result.match_field) end)
      |> Enum.uniq_by(fn result -> result.article.slug end)
      |> Enum.take(@max_results)
    end
  end

  def search(_), do: []

  defp find_matches(article, query_down) do
    []
    |> maybe_match(article, query_down, :title, article.title)
    |> maybe_match(article, query_down, :description, article.description)
    |> maybe_match(article, query_down, :tags, Enum.join(article.tags, " "))
    |> maybe_match(article, query_down, :body, article.plain_body)
  end

  defp maybe_match(acc, article, query_down, field, text) do
    if String.contains?(String.downcase(text), query_down) do
      snippet =
        case field do
          :body -> extract_snippet(article.plain_body, query_down)
          :description -> extract_snippet(article.description, query_down)
          _ -> nil
        end

      acc ++ [%{article: article, match_field: field, snippet: snippet}]
    else
      acc
    end
  end

  defp field_priority(:title), do: 0
  defp field_priority(:description), do: 1
  defp field_priority(:tags), do: 2
  defp field_priority(:body), do: 3

  @doc """
  Extracts a snippet of text around the first occurrence of the query.
  """
  def extract_snippet(text, query) when is_binary(text) and is_binary(query) do
    text_down = String.downcase(text)
    query_down = String.downcase(query)

    case :binary.match(text_down, query_down) do
      {pos, _len} ->
        start = max(0, pos - div(@snippet_length, 2))
        snippet = String.slice(text, start, @snippet_length)

        snippet =
          if start > 0,
            do: "..." <> String.replace(snippet, ~r/^\S*\s/, "", global: false),
            else: snippet

        snippet =
          if start + @snippet_length < String.length(text),
            do: String.replace(snippet, ~r/\s\S*$/, "", global: false) <> "...",
            else: snippet

        snippet

      :nomatch ->
        nil
    end
  end

  @doc """
  Highlights all occurrences of the query in the given text by wrapping them in <mark> tags.
  Returns a list of Phoenix.HTML safe iodata fragments.
  """
  def highlight(nil, _query), do: ""

  def highlight(text, query) when is_binary(text) and is_binary(query) do
    query = String.trim(query)

    if String.length(query) < 2 do
      text
    else
      ~r/#{Regex.escape(query)}/i
      |> Regex.split(text, include_captures: true)
      |> Enum.map(&highlight_part(&1, query))
    end
  end

  defp highlight_part(part, query) do
    if String.downcase(part) == String.downcase(query) do
      escaped = part |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string()
      Phoenix.HTML.raw("<mark class=\"bg-primary/20 text-primary rounded\">#{escaped}</mark>")
    else
      Phoenix.HTML.html_escape(part)
    end
  end
end
