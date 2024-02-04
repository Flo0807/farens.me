defmodule Website.Project.Project do
  @moduledoc """
  A resource representing a project.
  """
  use Website.Resource

  defstruct title: "",
            link: "",
            link_label: "",
            description: "",
            body: "",
            markdown: ""

  @impl Website.Resource
  def path, do: "priv/resources/projects"
end
