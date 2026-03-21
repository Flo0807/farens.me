defmodule WebsiteWeb.SearchLive do
  use WebsiteWeb, :live_component

  alias Website.Blog

  @impl true
  def mount(socket) do
    {:ok, assign(socket, query: "", results: [], selected_index: 0, open: false)}
  end

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  @impl true
  def handle_event("open", _params, socket) do
    {:noreply,
     socket
     |> assign(open: true)
     |> push_event("open-search", %{})}
  end

  def handle_event("search", %{"query" => query}, socket) do
    results = Blog.search_articles(query)
    {:noreply, assign(socket, query: query, results: results, selected_index: 0)}
  end

  def handle_event("navigate-selected", _params, socket) do
    navigate_to_selected(socket)
  end

  def handle_event("keydown", %{"key" => "ArrowDown"}, socket) do
    max_index = max(length(socket.assigns.results) - 1, 0)
    new_index = min(socket.assigns.selected_index + 1, max_index)

    {:noreply,
     socket
     |> assign(selected_index: new_index)
     |> push_event("scroll-to-selected", %{id: "search-result-#{new_index}"})}
  end

  def handle_event("keydown", %{"key" => "ArrowUp"}, socket) do
    new_index = max(socket.assigns.selected_index - 1, 0)

    {:noreply,
     socket
     |> assign(selected_index: new_index)
     |> push_event("scroll-to-selected", %{id: "search-result-#{new_index}"})}
  end

  def handle_event("keydown", %{"key" => "Enter"}, socket) do
    navigate_to_selected(socket)
  end

  def handle_event("keydown", %{"key" => "Escape"}, socket) do
    {:noreply, assign(socket, query: "", results: [], selected_index: 0, open: false)}
  end

  def handle_event("keydown", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("navigate", %{"slug" => slug}, socket) do
    {:noreply,
     socket
     |> assign(query: "", results: [], selected_index: 0, open: false)
     |> push_navigate(to: ~p"/blog/#{slug}")}
  end

  def handle_event("close", _params, socket) do
    {:noreply, assign(socket, query: "", results: [], selected_index: 0, open: false)}
  end

  defp navigate_to_selected(socket) do
    case Enum.at(socket.assigns.results, socket.assigns.selected_index) do
      nil ->
        {:noreply, socket}

      result ->
        {:noreply,
         socket
         |> assign(query: "", results: [], selected_index: 0, open: false)
         |> push_navigate(to: ~p"/blog/#{result.article.slug}")}
    end
  end

  defp match_field_label(:title), do: "in title"
  defp match_field_label(:description), do: "in description"
  defp match_field_label(:tags), do: "in tags"
  defp match_field_label(:body), do: "in content"

  defp highlight(text, query) do
    Blog.Search.highlight(text, query)
  end

  defp format_date(date) do
    Calendar.strftime(date, "%b %d, %Y")
  end
end
