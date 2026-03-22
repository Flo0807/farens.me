defmodule WebsiteWeb.HomeLive.Index do
  use WebsiteWeb, :live_view

  alias Website.Blog

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    articles = Blog.all_articles() |> Enum.take(3)

    socket =
      socket
      |> assign(:articles, articles)
      |> assign(:page_title, "Florian Arens - Software Engineer")
      |> assign(:og_image_text, "Florian Arens")
      |> assign(
        :meta_description,
        "Software Engineer passionate about leveraging AI to accelerate software development. Explore my blog, projects, and more."
      )

    {:ok, socket}
  end
end
