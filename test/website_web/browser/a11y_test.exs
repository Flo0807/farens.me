defmodule WebsiteWeb.A11yTest do
  use PhoenixTest.Playwright.Case, async: true

  alias PlaywrightEx.Frame

  @timeout Application.compile_env(:phoenix_test, [:playwright, :timeout], 5_000)

  @pages [
    "/",
    "/about",
    "/blog",
    "/blog/tag/elixir",
    # "/blog/hello-world",
    "/projects",
    "/legal-notice",
    "/privacy-policy"
  ]

  @themes ["light", "dark", "night", "sunset", "dracula"]

  @moduletag :playwright

  for theme <- @themes, page <- @pages do
    @tag page: page, theme: theme
    test "page #{page} with #{theme} theme has no accessibility violations", %{
      conn: conn,
      page: page,
      theme: theme
    } do
      conn
      |> set_theme(theme)
      |> visit(page)
      |> assert_a11y()
    end
  end

  defp set_theme(session, theme) do
    Frame.evaluate(
      session.frame_id,
      expression: "document.documentElement.setAttribute('data-theme','#{theme}')",
      timeout: @timeout
    )

    session
  end

  defp assert_a11y(session) do
    Frame.evaluate(session.frame_id, expression: A11yAudit.JS.axe_core(), timeout: @timeout)

    {:ok, json} = Frame.evaluate(session.frame_id, expression: "axe.run()", timeout: @timeout)

    json
    |> A11yAudit.Results.from_json()
    |> A11yAudit.Assertions.assert_no_violations()

    session
  end
end
