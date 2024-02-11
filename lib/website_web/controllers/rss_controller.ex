defmodule WebsiteWeb.RssController do
  @moduledoc """
  The RSS feed controller.
  """
  use WebsiteWeb, :controller
  use WebsiteWeb, :verified_routes

  alias Atomex.{Feed, Entry}
  alias Website.Blog

  @author "Florian Arens"
  @email "info@farens.me"

  def index(conn, _params) do
    articles = Blog.all_articles()
    feed = build_feed(articles)

    conn
    |> put_resp_content_type("application/rss+xml")
    |> send_resp(200, feed)
  end

  defp build_feed(articles) do
    Feed.new(url(~p"/"), DateTime.utc_now(), "Blog Feed")
    |> Feed.author(@author, email: @email)
    |> Feed.link(url(~p"/rss.xml"), rel: "self")
    |> Feed.entries(Enum.map(articles, &get_entry/1))
    |> Feed.build()
    |> Atomex.generate_document()
  end

  defp get_entry(article) do
    date_time = DateTime.new!(article.date, Time.from_iso8601!("00:00:00"), "Etc/UTC")

    Entry.new(url(~p"/blog/#{article.slug}"), date_time, article.title)
    |> Entry.link(url(~p"/blog/#{article.slug}"))
    |> Entry.author(@author, email: @email)
    |> Entry.content(article.description, type: "text")
    |> Entry.build()
  end
end
