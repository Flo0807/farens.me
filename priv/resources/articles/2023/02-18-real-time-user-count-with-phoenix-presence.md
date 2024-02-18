%{
  slug: "real-time-user-count-with-phoenix-presence",
  title: "Display the number of online users in real-time using Phoenix Presence",
  description: "Adding real-time functionality is often a challenge, but in Phoenix we already have built-in functionality to make our application live. We dive into how LiveView and Phoenix Presence can be used to build a real-time user count.", 
  published: true
}
---
Adding real-time functionality is often a challenge, but in Phoenix we already have built-in functionality to make our application live. We dive into how Phoenix Presence can be used to build a real-time user count.

## Introduction

I recently redesigned my website and published the first article in my blog. Along with the redesign, I added a live readers counter to blog posts that shows the number of active sessions in real time. As soon as you open the article page, the counter increases for each user currently online on that page and it decreases as soon as a session ends. You can try it out by watching the live counter in this article while opening and closing the page in different browser tabs.

In this post we will dive into how [Phoenix Presence](https://hexdocs.pm/phoenix/Phoenix.Presence.html) was used to build this feature in a few lines of code. I will also provide some background on the Phoenix LiveView lifecycle and the real-time publisher/subscriber service in Phoenix (called PubSub).

## The Problem

Adding real-time functionality to a web application for the first time is usually a challenge. While there are many packages and services available today that provide APIs and infrastructure for real-time functionality, you almost always have to rely on third-party applications.

You can decide whether to use a managed infrastructure for example provided by [Pusher](https://pusher.com/), [Ably](https://www.ably.io/) or [LiveBlocks](https://liveblocks.io/) or use a self-hosted solution (e.g. built with [Socket.io](https://socket.io/)). In either case, you will need to integrate the services or libraries into your application and learn how to use them. This process can be time-consuming and frustrating. In addition manged services can be expensive and self-hosted solutions require maintenance.

In Phoenix, we already have built-in functionality and infrastructure to make our application live. This is not surprising when we talk about building our application with **Live**Views.

You might say that some applications don't necessarily need real-time functionality, but in my opinion, value can be added to almost any application by providing real-time functionality. Even for a small blog that serves static articles, it is an eye-catcher to show the number of live readers. Adding real-time functionality to an application makes it more interactive and therefore more fun to use!

## Background

### LiveView Lifecycle

To understand why our LiveViews in Phoenix are live by design, we first need to understand the **Phoenix LiveView Lifecycle**.

When you send an HTTP request to a LiveView, you receive a server-rendered HTML response. After the initial HTML response, a websocket connection is established between the client and the LiveView. When the connection is established successfully, the view turns into a stateful view that can handle events and push updates to the client. In other words, a LiveView is a long-lived process that can handle multiple requests and events over time. The process is killed when the client leaves the page.

Elixir, and therefore LiveView processes, are lightweight and can handle a large number of concurrent connections, making it possible to have one LiveView process for each client. Each LiveView contains stateful values called socket assigns. The assigns are maintained on the server side and are used to render dynamic content in the view. Whenever the assigns change, the LiveView sends a message to the client to update the DOM (minimal JavaScript code that comes with LiveView takes care of the DOM updates for us). Clients can also send events to the LiveView process, which can be used to update the assigns and thus the view. It is important to note that only the necessary parts of the DOM are updated, which makes the application very efficient. LiveView only patches the DOM with the necessary changes.

The following example shows how to create a simple counter with LiveView. The counter is incremented by clicking a button and the value is displayed in the view.

```elixir
defmodule MyAppeWeb.CounterLive.Index do
  use MyAppeWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, counter: 0)}
  end

  def render(assigns) do
    ~H"""
    <p>Counter: <%= @counter %></p>
    <button phx-click="increment">Increment</button>
    """
  end

  def handle_event("increment", _params, socket) do
    {:noreply, assign(socket, counter: socket.assigns.counter + 1)}
  end
end
```

First the counter is set to 0 in the `mount/3` function. The `render/1` function is used to render the view and the `handle_event/3` function is used to handle the event when the button is clicked. The `handle_event/3` function increments the counter and updates the assigns. The LiveView process then sends a message to the client to update the DOM with the new counter value.

This architecture allows us to minimize the JavaScript code in our application while still being able to build interactive applications. Because of the Websocket connection, the LiveView process can push updates to the client, which makes it easy to add real-time functionality to our application. We do not need to fetch data from the server at regular intervals. Instead, the server can push updates to the client as the data changes.

The LiveView lifecycle makes it possible to build efficient real-time applications. The LiveView process can push updates to the client, and the client can send events to the LiveView process. If you want to learn more about the LiveView Lifecycle, I recommend reading the [Phoenix LiveView Documentation](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html).

### Phoenix PubSub

Phoenix PubSub is a real-time publisher/subscriber service that is used to broadcast messages to multiple subscribers. A subscriber can be a process and therefore can be a LiveView. If you have created a Phoenix application with the official generator, you probably have a PubSub server in your application.

If not, you can add the PubSub server to your application by adding the following line to your supervision tree:

```elixir
# lib/my_app/application.ex
children = [
  ...
  {Phoenix.PubSub, name: MyApp.PubSub}
]
```

You can now use the PubSub server to broadcast messages to subscribers. The following example shows how to subscribe to a topic and broadcast a message to that topic:

```elixir
Phoenix.PubSub.subscribe(MyApp.PubSub, "topic")
Phoenix.PubSub.broadcast(MyApp.PubSub, "topic", "Hello")
```

For more information about Phoenix PubSub and a list of all available features, see the [Phoenix PubSub documentation](https://hexdocs.pm/phoenix_pubsub/Phoenix.PubSub.html).

### Phoenix Presence

Phoenix Presence is built on top of Phoenix PubSub and is used to track the presence of users in a channel or process along with some metadata. The metadata can be used to track the state of the user, for example if the user is typing or online. Phoenix Presence also provides us with features like handling diffs of join and leave events in real time or fetching the current presence state. As we learned in the previous section, LiveViews are long-lived processes. This makes it possible to use Phoenix Presence to track the presence of users in a LiveView.

Phoenix Presence is easy to integrate into our application. We just need to add a presence module to our application and add it to our supervision tree. The following example shows how a presence module could look like:

```elixir
defmodule MyAppWeb.Presence do
  use Phoenix.Presence,
    otp_app: :my_app,
    pubsub_server: MyApp.PubSub
end
```

We use the `Phoenix.Presence` module to define our presence module. We need to specify the `otp_app` and the `pubsub_server`. The `otp_app` is the name of our application and the `pubsub_server` is the PubSub server we are using in our application. We then add the presence module to our supervision tree:

```elixir
children = [
  ...
  {Phoenix.PubSub, name: MyApp.PubSub},
  MyAppWeb.Presence,
  MyAppWeb.Endpoint
]
```

Make sure it is defined after the `Phoenix.PubSub` process in the supervision tree and before the `MyAppWeb.Endpoint` process.

That's it! We now have Phoenix Presence integrated into our application.

We are now able to use Phoenix Presence features like listing all presences in a process, getting the current presence state, or handling diffs of join and leave events in real time.

You can learn more about Phoenix Presence in the [Phoenix Presence documentation](https://hexdocs.pm/phoenix/Phoenix.Presence.html). There you will find a list of all features and how to use them.

## Real-time User Count

Let us return to live reader counting and combine the knowledge we gained in the previous sections to build the feature. We will use Phoenix Presence to track the presence of users in a LiveView.

To prepare, we need to add Phoenix Presence to our application. We will create a presence module that uses `Phoenix.Presence` and add it to our supervision tree. We will use the same code as shown in the Phoenix Presence section of this article.

Since Phoenix Presence uses Phoenix PubSub under the hood, we subscribe to a topic in our LiveView process that will be used to broadcast the presence events. Since we want to have a live reader count for each article, we need to subscribe to a unique topic for each article. We can use the article id as the topic along with a prefix to make the topic unique. 

Let's define a function that returns the topic for a given article:

```elixir
defp topic(%{id: id} = _article) do
  "article:#{id}"
end
```

We can now subscribe to the topic in the `mount/3` function of our LiveView process. We want to do this after the websocket connection between the client and LiveView has been established and not during the first render. We can use the `connected?/1` function to check this. We also need to tell Phoenix Presence that we want to track the presence of the user in the topic. We use the `track/3` function to do this.

```elixir
if connected?(socket) do
  Phoenix.PubSub.subscribe(MyApp.PubSub, topic(article))
  {:ok, _ref} = Presence.track(self(), topic(article), "live_reading", %{})
end
```

We pass the topic and PubSub name to the `subscribe/2` function. The `track/3` function takes the process, the topic, a key and metadata. The key is used to identify the presence and the metadata can be used to track the state of the user. In our case we only need to track the presence of the user, so we use an empty map as metadata.

We now have the user's presence tracked in the topic. We can use the `list/1` function to retrieve the presences in a given topic. We write a function that lists the presences for the topic of a given article and counts the number of presences under the given key. The returned value is the live readers count for the article or more generally the number of online users on the page.

```elixir
defp get_live_reading_count(article) do
  case Presence.list(topic(article)) do
    %{"live_reading" => %{metas: list}} -> Enum.count(list)
    _other -> 0
  end
end
```

We assign this value to the socket and use it to represent the number of live readers in the view.

```elixir
live_reading = get_live_reading_count(article)

socket =  assign(socket, live_reading: live_reading)
```

Now the live reader count can be displayed in the view. We now need to handle presence diffs to update the live reader count in real time. We use the `handle_info/2` function to listen for the `presence_diff` event sent by Phoenix Presence when a user joins or leaves. 

In the event handler we call the `get_live_reading_count/1` function and update the assigns with the new live reader count.

```elixir
def handle_info(%Broadcast{event: "presence_diff"} = _event, socket) do
  live_reading = get_live_reading_count(socket.assigns.article)

  {:noreply, assign(socket, :live_reading, live_reading)}
end
```

That's it! We now have a live reader counter for each article. The live reader count is updated in real time when a user enters or leaves the article page. You can fetch the value from the assigns in the view and display it wherever you want.

The full code for the live counter might look like this:

```elixir
defmodule MyAppWeb.BlogLive.Show do
  use MyAppWeb, :live_view

  alias Phoenix.Socket.Broadcast
  alias MyApp.Blog
  alias MyAppWeb.Presence

  @presence_key "live_reading"

  @impl Phoenix.LiveView
  def mount(%{"slug" => slug} = _params, _session, socket) do
    article = MyApp.Blog.get_article_by_slug(slug)
    live_reading = get_live_reading_count(article)

    if connected?(socket) do
      Phoenix.PubSub.subscribe(MyApp.PubSub, topic(article))
      {:ok, _ref} = Presence.track(self(), topic(article), @presence_key, %{})
    end

    socket =
      socket
      |> assign(:article, article)
      |> assign(:live_reading, live_reading)

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_info(%Broadcast{event: "presence_diff"} = _event, socket) do
    live_reading = get_live_reading_count(socket.assigns.article)

    {:noreply, assign(socket, :live_reading, live_reading)}
  end

  defp get_live_reading_count(article) do
    case Presence.list(topic(article)) do
      %{@presence_key => %{metas: list}} -> Enum.count(list)
      _other -> 0
    end
  end

  defp topic(%{id: id} = _article), do: "article:#{id}"
end
```

Feel free to use the code as a starting point for your own online user count indicator. You can also use the code to add other real-time features to your application.

## Conclusion

This article showed how to create a live reader count with Phoenix LiveView and Phoenix Presence in just a few lines of code. We also learned about the Phoenix LiveView Lifecycle and how it makes it easy to add real-time functionality to our application.


