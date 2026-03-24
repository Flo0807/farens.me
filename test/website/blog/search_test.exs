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

    test "results contain required keys" do
      results = Search.search("Hello World")
      assert results != []

      for result <- results do
        assert Map.has_key?(result, :article)
        assert Map.has_key?(result, :match_field)
        assert Map.has_key?(result, :snippet)
        assert result.match_field in [:title, :description, :tags, :body]
      end
    end

    test "title matches are ranked above body matches" do
      results = Search.search("Elixir")

      fields = Enum.map(results, & &1.match_field)
      title_idx = Enum.find_index(fields, &(&1 == :title))
      body_idx = Enum.find_index(fields, &(&1 == :body))

      if title_idx && body_idx do
        assert title_idx < body_idx
      end
    end

    test "trims leading and trailing whitespace from query" do
      results_trimmed = Search.search("Hello World")
      results_padded = Search.search("  Hello World  ")

      slugs_trimmed = Enum.map(results_trimmed, & &1.article.slug)
      slugs_padded = Enum.map(results_padded, & &1.article.slug)

      assert slugs_trimmed == slugs_padded
    end

    test "body matches include a snippet" do
      results = Search.search("Elixir")
      body_results = Enum.filter(results, &(&1.match_field == :body))

      for result <- body_results do
        assert is_binary(result.snippet)
      end
    end

    test "title and tag matches have nil snippet" do
      results = Search.search("Hello World")
      title_results = Enum.filter(results, &(&1.match_field in [:title, :tags]))

      assert title_results != []

      for result <- title_results do
        assert is_nil(result.snippet)
      end
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

    test "handles match at end of text" do
      text = "some words before the target"
      snippet = Search.extract_snippet(text, "target")
      assert snippet =~ "target"
      refute String.ends_with?(snippet, "...")
    end

    test "snippet does not exceed expected length" do
      text = String.duplicate("word ", 200) <> "needle" <> String.duplicate(" word", 200)
      snippet = Search.extract_snippet(text, "needle")
      assert String.length(snippet) <= 200
    end

    test "returns nil for empty text" do
      assert Search.extract_snippet("", "query") == nil
    end

    test "is case-insensitive" do
      text = "The Quick Brown Fox jumps over the lazy dog"
      snippet = Search.extract_snippet(text, "quick brown")
      assert snippet =~ "Quick Brown"
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
      result = Search.highlight("Hello", "a")
      html = Enum.map_join(result, &safe_to_string/1)
      assert html == "Hello"
    end

    test "handles nil text" do
      result = Search.highlight(nil, "test")
      html = Enum.map_join(result, &safe_to_string/1)
      assert html == ""
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

    test "is case-insensitive" do
      result = Search.highlight("Hello WORLD world", "world")
      html = Enum.map_join(result, &safe_to_string/1)

      assert html =~ "WORLD</mark>"
      assert html =~ "world</mark>"
    end

    test "highlights multiple occurrences" do
      result = Search.highlight("foo bar foo baz foo", "foo")
      html = Enum.map_join(result, &safe_to_string/1)

      assert length(Regex.scan(~r/<mark/, html)) == 3
    end

    test "preserves original case in highlighted text" do
      result = Search.highlight("Elixir is great", "elixir")
      html = Enum.map_join(result, &safe_to_string/1)

      assert html =~ "Elixir</mark>"
      refute html =~ "elixir</mark>"
    end

    test "escapes HTML entities in non-matched text" do
      result = Search.highlight("a <b>bold</b> match here", "match")
      html = Enum.map_join(result, &safe_to_string/1)

      assert html =~ "&lt;b&gt;"
      refute html =~ "<b>"
      assert html =~ "match</mark>"
    end

    test "returns plain text for whitespace-only query" do
      result = Search.highlight("Hello", "  ")
      html = Enum.map_join(result, &safe_to_string/1)
      assert html == "Hello"
    end
  end

  defp safe_to_string(safe) do
    Phoenix.HTML.safe_to_string(safe)
  end
end
