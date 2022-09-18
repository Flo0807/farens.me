defmodule WebsiteWeb.BlogLive.Index do
  use WebsiteWeb, :live_view

  alias Website.Repo

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(_params, url, socket) do
    {:ok, articles} = Repo.list(:articles)

    socket =
      socket
      |> assign(:url, url)
      |> assign(:articles, articles)

    {:noreply, socket}
  end
end
