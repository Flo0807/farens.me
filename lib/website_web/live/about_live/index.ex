defmodule WebsiteWeb.AboutLive.Index do
  use WebsiteWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "About Me - Florian Arens")
      |> assign(:og_image_text, "About")
      |> assign(
        :meta_description,
        "Learn about Florian Arens, a software developer and team lead passionate about Elixir, Phoenix, and functional programming."
      )

    {:ok, socket}
  end
end
