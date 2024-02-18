defmodule WebsiteWeb.Presence do
  @moduledoc """
  The presence module for the website.
  """
  use Phoenix.Presence,
    otp_app: :website,
    pubsub_server: Website.PubSub
end
