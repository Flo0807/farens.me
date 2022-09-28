defmodule WebsiteWeb.InitAssigns do
  import Phoenix.{Component, LiveView}

  def on_mount(:default, _params, _session, socket) do
    socket =
      socket
      |> attach_url_hook()

    {:cont, socket}
  end

  def attach_url_hook(socket) do
    attach_hook(socket, :attach_url_hook, :handle_params, fn
      _params, url, socket ->
        socket =
          socket
          |> assign(:url, url)

        {:cont, socket}
    end)
  end
end
