defmodule WebsiteWeb.A11yTest do
  use PhoenixTest.Playwright.Case, async: false

  alias PhoenixTest.Playwright.Frame

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

  for page <- @pages do
    @tag page: page
    test "page #{page} has no accessibility violations", %{conn: conn, page: page} do
      conn
      |> visit(page)
      |> assert_a11y()
    end
  end

  defp assert_a11y(session) do
    Frame.evaluate(session.frame_id, A11yAudit.JS.axe_core())

    results =
      session.frame_id
      |> Frame.evaluate("axe.run()")
      |> A11yAudit.Results.from_json()

    A11yAudit.Assertions.assert_no_violations(results)

    session
  end
end
