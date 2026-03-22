defmodule WebsiteWeb.SearchLive do
  use WebsiteWeb, :live_component

  alias Website.Blog

  @impl true
  def mount(socket) do
    {:ok, reset_search(socket) |> assign(loading: false)}
  end

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, id: assigns.id)}
  end

  @impl true
  def handle_event("open", _params, socket) do
    {:noreply,
     socket
     |> assign(open: true)
     |> push_event("open-search", %{})}
  end

  def handle_event("search", %{"query" => query}, socket) do
    socket = assign(socket, query: query, loading: true)
    results = Blog.search_articles(query)
    {:noreply, assign(socket, results: results, selected_index: 0, loading: false)}
  end

  def handle_event("navigate", %{"slug" => slug}, socket) do
    {:noreply,
     socket
     |> reset_search()
     |> push_navigate(to: ~p"/blog/#{slug}")}
  end

  def handle_event("close", _params, socket) do
    {:noreply, reset_search(socket)}
  end

  defp reset_search(socket) do
    socket
    |> assign(query: "", results: [], selected_index: 0, open: false)
    |> push_event("close-search", %{})
  end

  defp match_field_label(:title), do: "in title"
  defp match_field_label(:description), do: "in description"
  defp match_field_label(:tags), do: "in tags"
  defp match_field_label(:body), do: "in content"
  defp match_field_label(_), do: ""

  defp highlight(text, query) do
    Blog.Search.highlight(text, query)
  end

  defp format_date(date) do
    Calendar.strftime(date, "%b %d, %Y")
  end
end
