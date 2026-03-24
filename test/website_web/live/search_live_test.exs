defmodule WebsiteWeb.SearchLiveTest do
  use WebsiteWeb.ConnCase, async: true

  setup do
    %{conn: build_conn()}
  end

  describe "open and close" do
    test "search overlay is hidden by default", %{conn: conn} do
      conn
      |> visit("/")
      |> refute_has("#search-overlay")
    end

    test "opens search overlay", %{conn: conn} do
      conn
      |> visit("/")
      |> unwrap(fn view ->
        view
        |> Phoenix.LiveViewTest.element("#search-container")
        |> Phoenix.LiveViewTest.render_hook("open", %{})
      end)
      |> assert_has("#search-overlay")
      |> assert_has("input#search-input")
    end

    test "closes search overlay via close event", %{conn: conn} do
      conn
      |> visit("/")
      |> unwrap(fn view ->
        view
        |> Phoenix.LiveViewTest.element("#search-container")
        |> Phoenix.LiveViewTest.render_hook("open", %{})
      end)
      |> assert_has("#search-overlay")
      |> unwrap(fn view ->
        view
        |> Phoenix.LiveViewTest.element("#search-container [phx-click=\"close\"]")
        |> Phoenix.LiveViewTest.render_click()
      end)
      |> refute_has("#search-overlay")
    end

    test "closing search overlay resets state", %{conn: conn} do
      conn
      |> visit("/")
      |> unwrap(fn view ->
        view
        |> Phoenix.LiveViewTest.element("#search-container")
        |> Phoenix.LiveViewTest.render_hook("open", %{})
      end)
      |> unwrap(fn view ->
        view
        |> Phoenix.LiveViewTest.element("#search-container form")
        |> Phoenix.LiveViewTest.render_change(%{"query" => "elixir"})
      end)
      |> unwrap(fn view ->
        view
        |> Phoenix.LiveViewTest.element("#search-container [phx-click=\"close\"]")
        |> Phoenix.LiveViewTest.render_click()
      end)
      |> refute_has("#search-overlay")
      |> unwrap(fn view ->
        view
        |> Phoenix.LiveViewTest.element("#search-container")
        |> Phoenix.LiveViewTest.render_hook("open", %{})
      end)
      |> assert_has("#search-overlay")
      |> assert_has("#search-results", text: "Start typing to search articles...")
    end
  end

  describe "searching" do
    test "shows placeholder when query is empty", %{conn: conn} do
      conn
      |> visit("/")
      |> unwrap(fn view ->
        view
        |> Phoenix.LiveViewTest.element("#search-container")
        |> Phoenix.LiveViewTest.render_hook("open", %{})
      end)
      |> assert_has("#search-results", text: "Start typing to search articles...")
    end

    test "shows results for matching query", %{conn: conn} do
      conn
      |> visit("/")
      |> unwrap(fn view ->
        view
        |> Phoenix.LiveViewTest.element("#search-container")
        |> Phoenix.LiveViewTest.render_hook("open", %{})
      end)
      |> unwrap(fn view ->
        view
        |> Phoenix.LiveViewTest.element("#search-container form")
        |> Phoenix.LiveViewTest.render_change(%{"query" => "Phoenix"})
      end)
      |> assert_has("#search-results [role=option]")
    end

    test "shows no results message for non-matching query", %{conn: conn} do
      conn
      |> visit("/")
      |> unwrap(fn view ->
        view
        |> Phoenix.LiveViewTest.element("#search-container")
        |> Phoenix.LiveViewTest.render_hook("open", %{})
      end)
      |> unwrap(fn view ->
        view
        |> Phoenix.LiveViewTest.element("#search-container form")
        |> Phoenix.LiveViewTest.render_change(%{"query" => "xyznonexistent"})
      end)
      |> assert_has("#search-results", text: "No articles found for")
    end

    test "search is case-insensitive", %{conn: conn} do
      conn
      |> visit("/")
      |> unwrap(fn view ->
        view
        |> Phoenix.LiveViewTest.element("#search-container")
        |> Phoenix.LiveViewTest.render_hook("open", %{})
      end)
      |> unwrap(fn view ->
        view
        |> Phoenix.LiveViewTest.element("#search-container form")
        |> Phoenix.LiveViewTest.render_change(%{"query" => "phoenix"})
      end)
      |> assert_has("#search-results [role=option]")
    end

    test "ignores short queries", %{conn: conn} do
      conn
      |> visit("/")
      |> unwrap(fn view ->
        view
        |> Phoenix.LiveViewTest.element("#search-container")
        |> Phoenix.LiveViewTest.render_hook("open", %{})
      end)
      |> unwrap(fn view ->
        view
        |> Phoenix.LiveViewTest.element("#search-container form")
        |> Phoenix.LiveViewTest.render_change(%{"query" => "a"})
      end)
      |> refute_has("#search-results [role=option]")
    end

    test "trims whitespace from query", %{conn: conn} do
      conn
      |> visit("/")
      |> unwrap(fn view ->
        view
        |> Phoenix.LiveViewTest.element("#search-container")
        |> Phoenix.LiveViewTest.render_hook("open", %{})
      end)
      |> unwrap(fn view ->
        view
        |> Phoenix.LiveViewTest.element("#search-container form")
        |> Phoenix.LiveViewTest.render_change(%{"query" => "  Phoenix  "})
      end)
      |> assert_has("#search-results [role=option]")
    end

    test "shows match field labels", %{conn: conn} do
      conn
      |> visit("/")
      |> unwrap(fn view ->
        view
        |> Phoenix.LiveViewTest.element("#search-container")
        |> Phoenix.LiveViewTest.render_hook("open", %{})
      end)
      |> unwrap(fn view ->
        view
        |> Phoenix.LiveViewTest.element("#search-container form")
        |> Phoenix.LiveViewTest.render_change(%{"query" => "Presence"})
      end)
      |> assert_has("#search-results [role=option]", text: "in title")
    end
  end

  describe "navigation" do
    test "navigates to article when clicking a result", %{conn: conn} do
      conn
      |> visit("/")
      |> unwrap(fn view ->
        view
        |> Phoenix.LiveViewTest.element("#search-container")
        |> Phoenix.LiveViewTest.render_hook("open", %{})
      end)
      |> unwrap(fn view ->
        view
        |> Phoenix.LiveViewTest.element("#search-container form")
        |> Phoenix.LiveViewTest.render_change(%{"query" => "Hello World"})
      end)
      |> unwrap(fn view ->
        view
        |> Phoenix.LiveViewTest.element(~s(#search-container li[phx-value-slug="hello-world"]))
        |> Phoenix.LiveViewTest.render_click()
      end)
      |> assert_path("/blog/hello-world")
    end

    test "closes overlay after navigation", %{conn: conn} do
      conn
      |> visit("/")
      |> unwrap(fn view ->
        view
        |> Phoenix.LiveViewTest.element("#search-container")
        |> Phoenix.LiveViewTest.render_hook("open", %{})
      end)
      |> unwrap(fn view ->
        view
        |> Phoenix.LiveViewTest.element("#search-container form")
        |> Phoenix.LiveViewTest.render_change(%{"query" => "Hello World"})
      end)
      |> unwrap(fn view ->
        view
        |> Phoenix.LiveViewTest.element(~s(#search-container li[phx-value-slug="hello-world"]))
        |> Phoenix.LiveViewTest.render_click()
      end)
      |> assert_path("/blog/hello-world")
      |> refute_has("#search-overlay")
    end
  end
end
