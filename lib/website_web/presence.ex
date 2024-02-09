defmodule WebsiteWeb.Presence do
  use Phoenix.Presence,
    otp_app: :website,
    pubsub_server: Website.PubSub
end
