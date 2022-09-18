defmodule Website.Parser do
  def parse(file, resource) do
    File.read!(file)
    |> split()
    |> merge(resource)
  end

  def split(file) do
    [_, metadata, markdown] = String.split(file, "---", parts: 3)

    metadata = metadata_to_map(metadata)
    html = Earmark.as_html!(markdown)

    {metadata, html}
  end

  def metadata_to_map(metadata) do
    {:ok, map} = YamlElixir.read_from_string(metadata)

    Map.new(map, &key_to_atom(&1))
  end

  def key_to_atom({k, v}) do
    {String.to_atom(k), v}
  end

  def merge({metadata, html}, resource) do
    resource.__struct__()
    |> Map.merge(metadata)
    |> Map.put(:body, html)
    |> resource.init()
  end
end
