defmodule WebsiteWeb.AboutLive.Index do
  use WebsiteWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(_params, url, socket) do
    socket =
      socket
      |> assign(:url, url)

    {:noreply, socket}
  end
end
