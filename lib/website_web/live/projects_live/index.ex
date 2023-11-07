defmodule WebsiteWeb.ProjectsLive.Index do
  use WebsiteWeb, :live_view

  alias Website.Repo

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, projects} = Repo.list(:projects)

    socket =
      socket
      |> assign(:projects, projects)
      |> assign(:page_title, "Projects")

    {:ok, socket}
  end
end
