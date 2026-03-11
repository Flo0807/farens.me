defmodule WebsiteWeb.ProjectsLive.Index do
  use WebsiteWeb, :live_view

  alias Website.Projects

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    projects = Projects.all_projects()

    socket =
      socket
      |> assign(:projects, projects)
      |> assign(:page_title, "Projects - Florian Arens")
      |> assign(:og_image_text, "Projects")
      |> assign(
        :meta_description,
        "Explore projects built by Florian Arens, including open source tools and web applications using Elixir and Phoenix."
      )

    {:ok, socket}
  end
end
