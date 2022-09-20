defmodule WebsiteWeb.HomeLive.Index do
  use WebsiteWeb, :live_view

  alias Website.Repo

  def handle_params(_params, _url, socket) do
    {:ok, articles} = Repo.list(:articles)

    articles =
      articles
      |> Enum.shuffle()
      |> Enum.take(3)

    socket =
      socket
      |> assign(:articles, articles)

    {:noreply, socket}
  end
end
