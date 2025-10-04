defmodule WebsiteWeb.BlogLive.Show do
  use WebsiteWeb, :live_view

  alias Phoenix.Socket.Broadcast
  alias Website.Blog
  alias WebsiteWeb.Presence

  @presence_key "live_reading"

  @impl Phoenix.LiveView
  def mount(%{"slug" => slug} = _params, _session, socket) do
    article = Blog.get_article_by_slug(slug)

    if is_nil(article) do
      raise WebsiteWeb.ResourceNotFoundError, resource: :article, slug: slug
    end

    live_reading = get_live_reading_count(article)
    recommended_articles = Blog.get_recommended_articles(article, 2)

    if connected?(socket) do
      Phoenix.PubSub.subscribe(Website.PubSub, topic(article))
      {:ok, _ref} = Presence.track(self(), topic(article), @presence_key, %{ip: get_ip(socket)})
    end

    socket =
      socket
      |> assign(:article, article)
      |> assign(:page_title, article.title)
      |> assign(:live_reading, live_reading)
      |> assign(:recommended_articles, recommended_articles)
      |> SEO.assign(article)

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_info(%Broadcast{event: "presence_diff"} = _event, socket) do
    live_reading = get_live_reading_count(socket.assigns.article)

    {:noreply, assign(socket, :live_reading, live_reading)}
  end

  defp get_live_reading_count(article) do
    case Presence.list(topic(article)) do
      %{@presence_key => %{metas: list}} ->
        list
        |> Enum.uniq_by(fn %{ip: ip} -> ip end)
        |> Enum.count()

      _other ->
        0
    end
  end

  defp topic(%{id: id} = _article) do
    "article:#{id}"
  end

  defp get_ip(socket) do
    get_connect_info(socket, :x_headers)
    |> Enum.filter(fn {header, _value} -> header == "x-real-ip" end)
    |> then(fn
      [{_header, value}] ->
        value

      _other ->
        "0.0.0.0"
    end)
  end
end
