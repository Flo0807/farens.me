defmodule WebsiteWeb.BlogLive.Show do
  use WebsiteWeb, :live_view

  alias Website.Repo
  alias Website.DateUtils

  @impl Phoenix.LiveView
  def mount(%{"slug" => slug} = _params, _session, socket) do
    article = Repo.get_by_slug!(:articles, slug)

    socket =
      socket
      |> assign(:article, article)
      |> assign(:page_title, article.title)

    {:ok, socket}
  end
end
