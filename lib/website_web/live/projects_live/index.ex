defmodule WebsiteWeb.ProjectsLive.Index do
  use WebsiteWeb, :live_view

  alias Website.Projects

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    projects = Projects.all_projects()

    socket =
      socket
      |> assign(:projects, projects)
      |> assign(:page_title, "Projects")

    {:ok, socket}
  end
end
