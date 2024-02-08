defmodule WebsiteWeb.HomeLive.Index do
  use WebsiteWeb, :live_view

  alias Website.Blog

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    articles = Blog.all_articles() |> Enum.take(3)

    socket =
      socket
      |> assign(:articles, articles)
      |> assign(:page_title, "Software Developer")

    {:ok, socket}
  end
end
