defmodule Website.Blog.Article do
  @moduledoc """
  A resource representing an article.
  """
  @words_per_minute 200

  defstruct id: "",
            slug: "",
            title: "",
            date: nil,
            description: "",
            body: "",
            read_minutes: 0,
            published: false

  def build(filename, attrs, body) do
    [year, month_day_id] = filename |> Path.rootname() |> Path.split() |> Enum.take(-2)
    [month, day, id] = String.split(month_day_id, "-", parts: 3)
    date = Date.from_iso8601!("#{year}-#{month}-#{day}")
    read_minutes = calculate_read_minutes(body)

    struct!(
      __MODULE__,
      [id: id, date: date, body: body, read_minutes: read_minutes] ++ Map.to_list(attrs)
    )
  end

  defp calculate_read_minutes(html) do
    word_count =
      Floki.parse_fragment!(html)
      |> Floki.text()
      |> String.split(~r/\s+/)
      |> Enum.count()

    case div(word_count, @words_per_minute) do
      0 -> 1
      n -> n
    end
  end
end
