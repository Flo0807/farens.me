defmodule WebsiteWeb.BlogLive.Show do
  use WebsiteWeb, :live_view

  alias Website.Repo
  alias Website.Utils

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, url, socket) do
    article = Repo.get_by_slug!(:articles, id)

    socket =
      socket
      |> assign(:url, url)
      |> assign(:article, article)

    {:noreply, socket}
  end
end
