defmodule Website.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      WebsiteWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Website.PubSub},
      # Start the Endpoint (http/https)
      WebsiteWeb.Endpoint,
      # Start a worker by calling: Website.Worker.start_link(arg)
      # {Website.Worker, arg}
      Website.Repo
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Website.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WebsiteWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
