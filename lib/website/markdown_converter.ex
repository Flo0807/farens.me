defmodule Website.MarkdownConverter do
  @doc """
  Converts markdown to HTML.
  """

  def convert(_path, body, _attrs, _opts) do
    MDEx.to_html(body, extension: [header_ids: ""])
  end
end
