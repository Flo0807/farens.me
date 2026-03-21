defmodule WebsiteWeb.PrivacyLive.Index do
  use WebsiteWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Privacy Policy - Florian Arens")
      |> assign(:og_image_text, "Privacy Policy")
      |> assign(
        :meta_description,
        "Privacy policy and data protection information for farens.me"
      )

    {:ok, socket}
  end
end
