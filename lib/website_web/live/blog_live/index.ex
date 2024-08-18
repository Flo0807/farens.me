defmodule WebsiteWeb.BlogLive.Index do
  use WebsiteWeb, :live_view

  alias Website.Blog

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    all_tags = Blog.all_tags()

    socket =
      socket
      |> assign(:page_title, "Blog - Florian Arens")
      |> assign(:all_tags, all_tags)
      |> assign(:og_image_text, "Blog")

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _uri, socket) do
    tag =
      case Map.get(params, "tag") do
        nil -> nil
        tag -> String.downcase(tag)
      end

    articles = Blog.articles_by_tag(tag)

    socket =
      socket
      |> assign(:search_tag, tag)
      |> stream(:articles, articles, reset: true)

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("select-tag", %{"tag" => tag}, socket) do
    tag = String.downcase(tag)

    socket =
      case tag == socket.assigns.search_tag do
        true -> push_patch(socket, to: ~p"/blog")
        false -> push_patch(socket, to: ~p"/blog/tag/#{tag}")
      end

    {:noreply, socket}
  end
end
