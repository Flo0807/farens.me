defmodule WebsiteWeb.ProjectsLive.Index do
  use WebsiteWeb, :live_view

  alias Website.Repo

  def mount(_params, _session, socket) do
    {:ok, projects} = Repo.list(:projects)

    socket =
      socket
      |> assign(:projects, projects)

    {:ok, socket}
  end
end
