defmodule Website.Projects do
  @moduledoc """
  The projects context.
  """
  use NimblePublisher,
    build: Website.Projects.Project,
    from: Application.app_dir(:website, "priv/resources/projects/*.md"),
    as: :projects,
    html_converter: Website.MarkdownConverter

  @doc """
  Returns all projects.
  """
  def all_projects, do: @projects
end
