defmodule WebsiteWeb.InteractionTest do
  use PhoenixTest.Playwright.Case, async: true

  @moduletag :playwright
  @moduletag browser_context_opts: [viewport: %{width: 390, height: 844}]

  test "search can be closed with the keyboard after results arrive", %{conn: conn} do
    conn
    |> visit("/")
    |> click_button("Search articles")
    |> fill_in("Search articles", with: "Phoenix")
    |> assert_has("#search-results [role=option]")
    |> press("#search-input", "Tab")
    |> assert_has("#close-search:focus")
    |> press("#close-search", "Enter")
    |> refute_has("#search-overlay")
    |> assert_has("button[aria-label='Search articles']:focus")
  end

  test "navigation and topic filters work on a narrow screen", %{conn: conn} do
    conn
    |> visit("/")
    |> click_link("nav[aria-label='Main navigation'] a", "Blog")
    |> assert_path("/blog")
    |> click_button("Elixir")
    |> assert_path("/blog/tag/elixir")
    |> assert_has("main button[aria-pressed=true]", text: "Elixir")
    |> click_button("Elixir")
    |> assert_path("/blog")
    |> refute_has("main button[aria-pressed=true]")
  end

  test "theme choice survives navigation and a new page load", %{conn: conn} do
    conn
    |> visit("/")
    |> click("#theme_switch summary")
    |> click_button("Light")
    |> assert_has("html[data-theme=light]")
    |> click_link("nav[aria-label='Main navigation'] a", "About")
    |> assert_has("html[data-theme=light]")
    |> visit("/projects")
    |> assert_has("html[data-theme=light]")
    |> click("#theme_switch summary")
    |> click_button("Dark")
    |> assert_has("html[data-theme=dark]")
    |> visit("/blog")
    |> assert_has("html[data-theme=dark]")
  end

  @tag browser_context_opts: [viewport: %{width: 1440, height: 900}]
  test "desktop table of contents highlights the section reached by a link", %{conn: conn} do
    conn
    |> visit("/blog/how-to-get-user-ip-addresses-in-phoenix-liveview")
    |> click_link("#desktop-toc a", "The more reliable way")
    |> assert_has("#desktop-toc a[aria-current=location][href='#the-more-reliable-way']")
  end
end
