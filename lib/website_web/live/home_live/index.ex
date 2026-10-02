defmodule WebsiteWeb.HomeLive.Index do
  use WebsiteWeb, :live_view

  alias Website.Blog
  alias Website.Projects

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    articles = Blog.all_articles() |> Enum.take(3)
    projects = Projects.all_projects() |> Enum.take(2)

    socket =
      socket
      |> assign(:articles, articles)
      |> assign(:projects, projects)
      |> assign(:page_title, "Florian Arens - Lead Engineer")
      |> assign(:og_image_text, "Building software. Putting AI to practical use.")
      |> assign(
        :meta_description,
        "Florian Arens, Lead Engineer at naymspace. I build software, put AI to practical use, and share what I learn through blog posts and my own open source projects."
      )

    {:ok, socket}
  end
end
