defmodule WebsiteWeb.BlogLive.Index do
  use WebsiteWeb, :live_view

  alias Website.Repo

  def handle_params(_params, _url, socket) do
    {:ok, articles} = Repo.list(:articles)

    socket =
      socket
      |> assign(:articles, articles)

    {:noreply, socket}
  end
end
