defmodule Website.MarkdownConverterTest do
  use ExUnit.Case, async: true

  alias Website.MarkdownConverter

  for {language, code} <- [
        {"elixir", "# A comment\ndefmodule Example do\n  def hello, do: :world\nend"},
        {"javascript", "const answer = 42;"},
        {"html", "<style>p { color: red; }</style><script>const answer = 42;</script>"},
        {"yaml", "name: CI\non: push"},
        {"bash", "echo \"hello\""}
      ] do
    test "highlights #{language} code blocks" do
      html =
        MarkdownConverter.convert(
          "article.md",
          "```#{unquote(language)}\n#{unquote(code)}\n```",
          %{},
          []
        )

      document = Floki.parse_fragment!(html)
      assert Floki.find(document, "pre code span[style]") != []
    end
  end

  test "preserves heading anchors and automatic links" do
    html = MarkdownConverter.convert("article.md", "## Hello World\n\nhttps://farens.me", %{}, [])
    document = Floki.parse_fragment!(html)

    assert Floki.find(document, "#hello-world") != []
    assert Floki.find(document, "a[href='https://farens.me']") != []
  end
end
