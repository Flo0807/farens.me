defmodule WebsiteWeb.BlogLive.Index do
  use WebsiteWeb, :live_view

  alias Website.Blog

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    articles = Blog.all_articles()

    socket =
      socket
      |> assign(:articles, articles)
      |> assign(:page_title, "Blog - Florian Arens")

    {:ok, socket}
  end
end
