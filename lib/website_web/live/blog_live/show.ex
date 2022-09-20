defmodule WebsiteWeb.BlogLive.Show do
  use WebsiteWeb, :live_view

  alias Website.Repo
  alias Website.Utils

  def handle_params(%{"id" => id}, _url, socket) do
    article = Repo.get_by_slug!(:articles, id)

    socket =
      socket
      |> assign(:article, article)

    {:noreply, socket}
  end
end
