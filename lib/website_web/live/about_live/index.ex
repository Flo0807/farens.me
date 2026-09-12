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
        "Meet Florian Arens, Lead Engineer at naymspace. I build web applications with Elixir and Phoenix LiveView and help teams use AI to make everyday work easier."
      )

    {:ok, socket}
  end
end
