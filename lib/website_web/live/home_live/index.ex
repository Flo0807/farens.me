defmodule WebsiteWeb.HomeLive.Index do
  use WebsiteWeb, :live_view

  alias Website.Repo

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, articles} = Repo.list(:articles)

    articles = Enum.take(articles, 3)

    socket =
      socket
      |> assign(:articles, articles)
      |> assign(:page_title, "Software Developer")

    {:ok, socket}
  end
end
