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
      |> assign(:page_title, "Florian Arens - Software Engineer")
      |> assign(:og_image_text, "Florian Arens")
      |> assign(
        :meta_description,
        "Software Engineer passionate about leveraging AI to accelerate software development. Explore my blog, projects, and more."
      )

    {:ok, socket}
  end
end
