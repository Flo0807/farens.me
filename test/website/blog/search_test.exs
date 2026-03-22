defmodule Website.Blog.SearchTest do
  use ExUnit.Case, async: true

  alias Website.Blog.Search

  describe "search/1" do
    test "returns empty list for empty query" do
      assert Search.search("") == []
    end

    test "returns empty list for single character query" do
      assert Search.search("a") == []
    end

    test "returns empty list for nil" do
      assert Search.search(nil) == []
    end

    test "returns empty list for whitespace-only query" do
      assert Search.search("   ") == []
    end

    test "handles very long query without crashing" do
      results = Search.search(String.duplicate("a", 500))
      assert is_list(results)
    end

    test "returns results matching article titles" do
      results = Search.search("Hello World")
      assert results != []
      assert Enum.any?(results, fn r -> r.match_field == :title end)
    end

    test "search is case-insensitive" do
      results_lower = Search.search("hello world")
      results_upper = Search.search("HELLO WORLD")

      assert length(results_lower) == length(results_upper)

      slugs_lower = Enum.map(results_lower, & &1.article.slug) |> Enum.sort()
      slugs_upper = Enum.map(results_upper, & &1.article.slug) |> Enum.sort()

      assert slugs_lower == slugs_upper
    end

    test "deduplicates results by slug, keeping highest priority match" do
      results = Search.search("Elixir")
      slugs = Enum.map(results, & &1.article.slug)
      assert slugs == Enum.uniq(slugs)
    end

    test "returns at most 10 results" do
      results = Search.search("the")
      assert length(results) <= 10
    end
  end

  describe "extract_snippet/2" do
    test "extracts snippet around match" do
      text = String.duplicate("word ", 50) <> "target" <> String.duplicate(" word", 50)
      snippet = Search.extract_snippet(text, "target")

      assert snippet =~ "target"
      assert String.contains?(snippet, "...")
    end

    test "returns nil when no match found" do
      assert Search.extract_snippet("some text", "nonexistent") == nil
    end

    test "handles match at beginning of text" do
      snippet = Search.extract_snippet("target is at the start", "target")
      assert snippet =~ "target"
      refute String.starts_with?(snippet, "...")
    end

    test "handles Unicode text with accented characters and emoji" do
      text = "Le café est délicieux et le résumé est prêt 🎉 pour la fête"
      snippet = Search.extract_snippet(text, "résumé")

      assert snippet =~ "résumé"
    end
  end

  describe "highlight/2" do
    test "wraps matched text in mark tags" do
      result = Search.highlight("Hello World", "World")
      html = Enum.map_join(result, &safe_to_string/1)

      assert html =~ "<mark"
      assert html =~ "World</mark>"
    end

    test "returns original text for short query" do
      assert Search.highlight("Hello", "a") == "Hello"
    end

    test "handles nil text" do
      assert Search.highlight(nil, "test") == ""
    end

    test "escapes HTML in query to prevent XSS" do
      malicious = "<script>alert(1)</script>"
      text = "before #{malicious} after"
      result = Search.highlight(text, malicious)
      html = Enum.map_join(result, &safe_to_string/1)

      refute html =~ "<script>"
      refute html =~ "</script>"
      assert html =~ "&lt;script&gt;"
      assert html =~ "<mark"
    end

    test "returns escaped empty text for empty string" do
      result = Search.highlight("", "query")
      html = Enum.map_join(result, &safe_to_string/1)

      assert html == ""
    end
  end

  defp safe_to_string(str) when is_binary(str), do: str

  defp safe_to_string(safe) do
    Phoenix.HTML.safe_to_string(safe)
  end
end
