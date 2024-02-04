defmodule Website.Parser do
  @moduledoc """
  A parser for resources.
  """

  @doc """
  Parses a file and merges it with a resource.
  """
  def parse(file, resource) do
    File.read!(file)
    |> split()
    |> merge(resource)
  end

  defp split(file) do
    [_, metadata, markdown] = String.split(file, "---", parts: 3)

    metadata = metadata_to_map(metadata)
    html = MDEx.to_html(markdown)

    {metadata, html, markdown}
  end

  defp metadata_to_map(metadata) do
    {:ok, map} = YamlElixir.read_from_string(metadata)

    Map.new(map, &key_to_atom(&1))
  end

  defp key_to_atom({k, v}) do
    {String.to_atom(k), v}
  end

  defp merge({metadata, html, markdown}, resource) do
    resource.__struct__()
    |> Map.merge(metadata)
    |> Map.put(:body, html)
    |> Map.put(:markdown, markdown)
    |> resource.init()
  end
end
