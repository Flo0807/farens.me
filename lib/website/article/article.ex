defmodule Website.Article.Article do
  @moduledoc """
  A resource representing an article.
  """
  use Website.Resource

  @words_per_minute 200

  defstruct slug: "",
            title: "",
            date: nil,
            description: "",
            body: "",
            read_minutes: 0,
            published: false,
            markdown: ""

  @impl Website.Resource
  def path, do: "priv/resources/articles"

  @impl Website.Resource
  def init(resource) do
    resource
    |> Map.put(:date, Date.from_iso8601!(resource.date))
    |> Map.put(:read_minutes, calculate_read_minutes(resource.markdown))
  end

  defp calculate_read_minutes(markdown) do
    word_count =
      markdown
      |> String.split(~r/\s+/)
      |> Enum.count()

    case div(word_count, @words_per_minute) do
      0 -> 1
      n -> n
    end
  end
end
