defmodule WebsiteWeb.AboutLive.Index do
  use WebsiteWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "About Me - Florian Arens")
      |> assign(:og_image_text, "About")

    {:ok, socket}
  end
end
