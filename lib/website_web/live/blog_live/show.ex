defmodule WebsiteWeb.BlogLive.Show do
  use WebsiteWeb, :live_view

  alias Website.Blog

  @impl Phoenix.LiveView
  def mount(%{"slug" => slug} = _params, _session, socket) do
    article = Blog.get_article_by_slug(slug)

    if is_nil(article) do
      raise Phoenix.Router.NoRouteError
    end

    socket =
      socket
      |> assign(:article, article)
      |> assign(:page_title, article.title)

    {:ok, socket}
  end
end
