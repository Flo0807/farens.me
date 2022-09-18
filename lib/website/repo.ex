defmodule Website.Repo do
  use GenServer

  alias Website.Parser

  @resources [
    articles: Website.Articles.Article
  ]

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_) do
    state =
      Enum.map(@resources, fn {name, resource} ->
        items =
          Path.wildcard("#{resource.path()}/*.md")
          |> Enum.map(&Parser.parse(&1, resource))
          |> Enum.sort(&resource.compare(&1, &2))

        {name, items}
      end)

    {:ok, state}
  end

  def list(resource) do
    GenServer.call(__MODULE__, {:list, resource})
  end

  def get_by_slug(resource, slug) do
    GenServer.call(__MODULE__, {:get_by_slug, resource, slug})
  end

  def get_by_slug!(resource, slug) do
    case GenServer.call(__MODULE__, {:get_by_slug, resource, slug}) do
      {:ok, item} -> item
      {:error, _} -> raise WebsiteWeb.NoResourceFoundError, resource: resource, slug: slug
    end
  end

  def handle_call({:list, resource}, _from, state) do
    list = Keyword.get(state, resource)

    {:reply, {:ok, list}, state}
  end

  def handle_call({:get_by_slug, resource, slug}, _from, state) do
    list = Keyword.get(state, resource)
    item = Enum.find(list, &(&1.slug == slug))

    result =
      case item do
        nil -> {:error, :not_found}
        _ -> {:ok, item}
      end

    {:reply, result, state}
  end
end
