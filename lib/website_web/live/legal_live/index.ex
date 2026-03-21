defmodule WebsiteWeb.LegalLive.Index do
  use WebsiteWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Legal Notice - Florian Arens")
      |> assign(:og_image_text, "Legal Notice")
      |> assign(
        :meta_description,
        "Legal notice and contact information for farens.me"
      )

    {:ok, socket}
  end
end
