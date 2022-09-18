defmodule Website.Articles.Article do
  defstruct slug: "",
            title: "",
            date: nil,
            summary: "",
            published: false

  def path, do: "priv/resources/articles"

  def init(resource) do
    resource
    |> Map.put(:date, Date.from_iso8601!(resource.date))
  end

  def compare(x, y), do: Timex.compare(x.date, y.date) > 0
end
