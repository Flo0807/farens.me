%{
  slug: "how-to-get-user-ip-addresses-in-phoenix-liveview",
  title: "How to Get User IP Addresses in Phoenix LiveView",
  description: "Learn how to reliably obtain user IP addresses in Phoenix LiveView applications, whether you're deploying directly or behind a reverse proxy. We'll explore both peer data and header-based approaches.",
  published: true,
  tags: ["Elixir", "LiveView", "Networking", "Phoenix"],
}
---
Learn how to reliably obtain user IP addresses in Phoenix LiveView applications, whether you're deploying directly or behind a reverse proxy. We'll explore both peer data and header-based approaches.

## Introduction

Sometimes you need to know the IP address of the user in your Phoenix LiveView application. This can be useful for several reasons, such as rate limiting, logging, or security. In this article we'll explain different ways to get the user's IP address and talk about problems that may occur.

## Fetch IP address from peer data

Phoenix LiveView provides a way to fetch the user's IP address from the peer data. The peer data is a map that contains information about the connection.

To access the peer data, you can use the [`Phoenix.LiveView.get_connect_info/2`](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#get_connect_info/2) function.

```elixir
defmodule MyAppWeb.TestLive do
  use MyAppWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    peer_data = get_connect_info(socket, :peer_data)
    IO.inspect(peer_data, label: :peer_data)

    {:ok, socket}
  end
end
```

The `get_connect_info/2` function takes two arguments: the socket and the key of the data you want to fetch. In this case, we're passing the `peer_data` key.

You'll notice from your logs that `peer_data` is `nil`.

```bash
peer_data: nil
```

The reason for this is that the peer data is not available by default. To enable it, you need to declare the `connect_info` you want to receive in your `endpoint.ex` file.

```elixir
socket "/live", Phoenix.LiveView.Socket,
  # add `:peer_data` to the connect_info list
  websocket: [connect_info: [:peer_data, session: @session_options]]
```

After adding `:peer_data` to the `connect_info`, you'll see the peer data map in your logs.

```bash
peer_data: %{port: 50526, address: {127, 0, 0, 1}, ssl_cert: nil}
```

The `peer_data` map contains the `address` key, which looks like a reference to the user's IP address.

We could extract this adress and assign it to the socket. Note that the address is a tuple, so you might want to convert it to a string first.

## The problem

If your application is deployed directly to the internet and handles traffic directly, the above method works fine and you'll get the user's IP address. However, as soon as you deploy your application behind a reverse proxy, you'll encounter a problem. The `peer_data` map will contain the IP address of the proxy that forwards the requests, not the user's IP address. From the perspective of your application, all requests will come from the proxy and not the actual user. So you always end up with the same IP address.

## The more reliable way

To get the user's IP address when your application is behind a reverse proxy, we need a different approach. Another way to get the user's IP address is to look at the request headers. By default, most proxies will add the user's IP address as a header to the request (e.g. `x-real-ip` or `x-forwarded-for`). This way applications behind the proxy can still access the user's IP address.

We can access the headers of a request the same way we access the peer data. For this, we first need to add the `x_headers` key to the `connect_info` in the `endpoint.ex` file.

```elixir
socket "/live", Phoenix.LiveView.Socket,
  # add `:x_headers` to the connect_info
  websocket: [connect_info: [:x_headers, session: @session_options]]
```

Now we can access the headers of the request in our LiveView using the `get_connect_info/2` function.

```elixir
defmodule MyAppWeb.TestLive do
  use MyAppWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    x_headers = get_connect_info(socket, :x_headers)
    IO.inspect(x_headers, label: :x_headers)

    {:ok, socket}
  end
end
```

Note that we can't test this locally, as the headers are added by the proxy. But you should see the headers in your logs when you deploy your application.

We can now extract the user's IP address from the `x-real-ip` header and assign it to the socket.

```elixir
defmodule MyAppWeb.TestLive do
  use MyAppWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    ip = get_ip(socket)

    socket = assign(socket, :ip, ip)

    {:ok, socket}
  end

  defp get_ip(socket) do
    get_connect_info(socket, :x_headers)
    |> Enum.filter(fn {header, _value} -> header == "x-real-ip" end)
    |> then(fn
      [{_header, value}] ->
        value

      _other ->
        "0.0.0.0"
    end)
  end
end
```

Make sure to check if your proxy adds the user's IP address to the `x-real-ip` header. If not, you might need to look for a different header. The `x-forwarded-for` header is another common header that proxies use to keep track of the user's IP address.

Also note that `get_connect_info/2` is only available in the `mount` function.

## Conclusion

This article showed how to fetch the user's IP address in a Phoenix LiveView application. We explained how to access the peer data and the request headers and talked about the problems that may occur when your application is behind a reverse proxy. We also provided a more reliable way to get the user's IP address in such cases.

## Sources

- Explanation of the `x-forwarded-for` header in detail: [https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Forwarded-For](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Forwarded-For)
- The difference between `x-real-ip` and `x-forwarded-for` header: [https://stackoverflow.com/a/72586833/21905032](https://stackoverflow.com/a/72586833/21905032)
- Fetching the client's IP adress in a LiveView: [https://stackoverflow.com/a/58584065/21905032](https://stackoverflow.com/a/58584065/21905032)
