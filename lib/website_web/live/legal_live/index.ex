defmodule WebsiteWeb.LegalLive.Index do
  use WebsiteWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, "Legal Notice - Florian Arens")}
  end
end
