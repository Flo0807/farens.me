defmodule WebsiteWeb.BlogLive.Index do
  use WebsiteWeb, :live_view

  alias Website.Repo

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, articles} = Repo.list(:articles)

    socket =
      socket
      |> assign(:articles, articles)
      |> assign(:page_title, "Blog")

    {:ok, socket}
  end
end
