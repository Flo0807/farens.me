defmodule WebsiteWeb.BlogLive.Show do
  use WebsiteWeb, :live_view

  alias Website.Repo
  alias Website.Utils

  def mount(%{"id" => id}, _session, socket) do
    article = Repo.get_by_slug!(:articles, id)

    socket =
      socket
      |> assign(:article, article)

    {:ok, socket}
  end
end
