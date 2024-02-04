defmodule WebsiteWeb.InitAssigns do
  @moduledoc """
  Initializes assigns for the live views.
  """
  import Phoenix.{Component, LiveView}

  @doc """
  Calls all the hooks for the given event.
  """
  def on_mount(:default, _params, _session, socket) do
    socket =
      socket
      |> attach_current_url_hook()

    {:cont, socket}
  end

  @doc """
  Attaches the current URL to the socket.
  """
  def attach_current_url_hook(socket) do
    attach_hook(socket, :attach_url_hook, :handle_params, fn
      _params, url, socket ->
        socket =
          socket
          |> assign(:current_url, url)

        {:cont, socket}
    end)
  end
end
