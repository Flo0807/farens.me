defmodule Website.Repo do
  @moduledoc """
  A repository for resources.
  """
  use GenServer

  alias Website.Parser

  @resources [
    articles: Website.Article.Article,
    projects: Website.Project.Project
  ]

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_) do
    resources =
      Enum.map(@resources, fn {name, resource} ->
        items =
          Application.app_dir(:website, "#{resource.path()}/**/*.md")
          |> Path.wildcard()
          |> Enum.map(&Parser.parse(&1, resource))
          |> Enum.sort(&resource.compare(&1, &2))

        {name, items}
      end)

    {:ok, resources}
  end

  @doc """
  Lists all resources of a given type.
  """
  def list(resource) do
    GenServer.call(__MODULE__, {:list, resource})
  end

  @doc """
  Gets a resource by its slug.
  """
  def get_by_slug!(resource, slug) do
    case GenServer.call(__MODULE__, {:get_by_slug, resource, slug}) do
      {:ok, item} -> item
      {:error, _} -> raise WebsiteWeb.ResourceNotFoundError, resource: resource, slug: slug
    end
  end

  # GenServer callbacks

  def handle_call({:list, resource_name}, _from, resources) do
    list = Keyword.get(resources, resource_name)

    {:reply, {:ok, list}, resources}
  end

  def handle_call({:get_by_slug, resource_name, slug}, _from, resources) do
    list = Keyword.get(resources, resource_name)
    item = Enum.find(list, &(&1.slug == slug))

    result =
      case item do
        nil -> {:error, :not_found}
        _ -> {:ok, item}
      end

    {:reply, result, resources}
  end
end
