defmodule WebsiteWeb.AboutLive.Index do
  use WebsiteWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, "About")}
  end
end
