defmodule Website.Articles.Article do
  use Website.Resource

  defstruct slug: "",
            title: "",
            date: nil,
            summary: "",
            published: false

  @impl Website.Resource
  def path, do: "priv/resources/articles"

  @impl Website.Resource
  def init(resource) do
    resource
    |> Map.put(:date, Date.from_iso8601!(resource.date))
  end

  @impl Website.Resource
  def compare(x, y), do: Timex.compare(x.date, y.date) > 0
end
