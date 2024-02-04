defmodule WebsiteWeb.Router do
  use WebsiteWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {WebsiteWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", WebsiteWeb do
    pipe_through :browser

    live_session :default, on_mount: WebsiteWeb.InitAssigns do
      live "/", HomeLive.Index, :index
      live "/about", AboutLive.Index, :index
      live "/blog", BlogLive.Index, :index
      live "/blog/:slug", BlogLive.Show, :show
      live "/projects", ProjectsLive.Index, :index
      live "/legal-notice", LeagalLive.Index, :index
      live "/privacy-policy", PrivacyLive.Index, :index
    end
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:website, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: WebsiteWeb.Telemetry
    end
  end
end
