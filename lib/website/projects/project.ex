defmodule Website.Projects.Project do
  use Website.Resource

  defstruct title: "",
            link: "",
            link_label: "",
            description: ""

  @impl Website.Resource
  def path, do: "priv/resources/projects"
end
