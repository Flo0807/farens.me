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
            tags: [],
            body: "",
            read_minutes: 0,
            heading_links: [],
            published: false

  def build(filename, attrs, body) do
    [year, month_day_id] = filename |> Path.rootname() |> Path.split() |> Enum.take(-2)
    [month, day, id] = String.split(month_day_id, "-", parts: 3)
    date = Date.from_iso8601!("#{year}-#{month}-#{day}")

    read_minutes = calculate_read_minutes(body)
    heading_links = parse_headings(body)

    struct!(
      __MODULE__,
      [id: id, date: date, body: body, read_minutes: read_minutes, heading_links: heading_links] ++
        Map.to_list(attrs)
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

  defp parse_headings(body) do
    body
    |> Floki.parse_fragment!()
    |> Enum.reduce([], fn
      {"h2", _class, child} = el, acc ->
        acc ++ [%{label: Floki.text(el), href: get_href(child), childs: []}]

      {"h3", _class, child} = el, acc ->
        List.update_at(acc, -1, fn %{childs: subs} = h2 ->
          %{h2 | childs: subs ++ [%{label: Floki.text(el), href: get_href(child), childs: []}]}
        end)

      _other, acc ->
        acc
    end)
  end

  def get_href(heading_element) do
    attr = heading_element |> Floki.find("a") |> Floki.attribute("href")

    case attr do
      [] -> nil
      [href | _] -> href
    end
  end
end
