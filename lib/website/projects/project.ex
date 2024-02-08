defmodule Website.Projects.Project do
  @moduledoc """
  A resource representing a project.
  """
  defstruct id: "",
            title: "",
            link: "",
            link_label: "",
            description: "",
            body: "",
            markdown: ""

  def build(filename, attrs, body) do
    id = filename |> Path.rootname() |> Path.split() |> List.last()

    struct!(
      __MODULE__,
      [id: id, body: body] ++ Map.to_list(attrs)
    )
  end
end
