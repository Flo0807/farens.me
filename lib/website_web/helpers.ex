defmodule WebsiteWeb.Helpers do
  use Phoenix.{Component, HTML}

  alias Website.Utils
  alias WebsiteWeb.Router.Helpers, as: Routes

  import WebsiteWeb.Components.ColorSchemeSwitch

  def merge_class(%{class: class}, default), do: class <> " " <> default
  def merge_class(_, default), do: default

  attr :url, :string, required: true, doc: "The current url."

  def header(assigns) do
    ~H"""
    <div x-data="{ mobile_menu: false }">
      <header class="flex justify-center sm:px-8 lg:px-16">
        <div class="flex w-full max-w-7xl items-center justify-between px-8 pt-6 sm:px-10 lg:px-16">
          <.link navigate="/" class="group shadow-zinc-800/5 shadow-lg">
            <img
              class="inline-block h-8 w-8 rounded-full ring-2 ring-white group-hover:ring-cyan-400"
              src="/images/me.jpg"
              alt="logo"
            />
          </.link>
          <nav class="bg-white/90 ring-zinc-900/5 shadow-zinc-800/5 hidden rounded-full px-6 text-zinc-800 shadow-lg ring-1 dark:ring-white/10 dark:bg-zinc-800 dark:text-zinc-100 md:block">
            <ul class="flex space-x-6 font-medium">
              <%= for %{to: to, label: label} <- header_links() do %>
                <li class={
                "relative px-3 py-2" <>
                  " " <> if active?(@url, to), do: "text-cyan-500 dark:text-cyan-400", else: "hover:text-cyan-500 hover:dark:text-cyan-400"
              }>
                  <.link navigate={to}>
                    <%= label %>
                  </.link>
                  <%= if active?(@url, to) do %>
                    <span class="from-cyan-400/0 via-cyan-500/80 to-cyan-500/0 absolute inset-x-1 -bottom-px h-px bg-gradient-to-r dark:via-cyan-400/80 dark:to-cyan-400/0">
                    </span>
                  <% end %>
                </li>
              <% end %>
            </ul>
          </nav>

          <div
            class="bg-white/90 ring-zinc-900/5 shadow-zinc-800/5 flex cursor-pointer items-center space-x-2 rounded-full px-4 py-2 text-zinc-800 shadow-lg ring-1 dark:ring-white/10 dark:bg-zinc-800 dark:text-zinc-100 md:hidden"
            @click="mobile_menu = true"
          >
            <p>Menu</p>
            <Heroicons.chevron_down solid class="h-5 w-5" />
          </div>

          <.color_scheme_switch />
        </div>

        <.mobile_nav />
      </header>
    </div>
    """
  end

  def mobile_nav(assigns) do
    ~H"""
    <div x-show="mobile_menu" @keydown.escape.window="mobile_menu = false">
      <div class="bg-zinc-900/80 fixed inset-0 z-50 transition-opacity"></div>

      <div class="fixed inset-0 z-50 my-4 flex transform items-center justify-center overflow-hidden px-4 sm:px-6">
        <div
          @click.outside="mobile_menu = false"
          class="max-h-full w-full max-w-xl overflow-auto rounded bg-white shadow-lg dark:bg-zinc-800"
        >
          <div class="border-b border-gray-100 px-5 py-3 dark:border-zinc-700">
            <div class="flex items-center justify-between">
              <p class="font-semibold text-zinc-800 dark:text-gray-200">
                Navigation
              </p>

              <button @click="mobile_menu = false">
                <Heroicons.x_mark solid class="h-5 w-5 dark:text-white" />
              </button>
            </div>
          </div>
          <div class="p-5">
            <nav class="flex flex-col space-y-6">
              <.link
                :for={%{to: to, label: label} <- header_links()}
                navigate={to}
                class="dark:text-gray-200"
              >
                <%= label %>
              </.link>
            </nav>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp header_links do
    [
      %{to: "/", label: "Home"},
      %{to: "/about", label: "About"},
      %{to: "/blog", label: "Blog"},
      %{to: "/projects", label: "Projects"}
    ]
  end

  defp active?(current, to) do
    %{path: path} = URI.parse(current)

    if to == "/", do: path == to, else: String.starts_with?(path, to)
  end

  attr :class, :string, default: "", doc: "Additional classes to be added to the footer."
  attr :url, :string, required: true, doc: "The current url."

  def footer(assigns) do
    ~H"""
    <footer class={"#{@class} flex justify-center px-8 sm:px-10 lg:px-16"}>
      <div class="w-full max-w-7xl border-t border-zinc-300 pt-8 pb-16 dark:border-zinc-700">
        <div class="flex flex-col items-center space-y-2 px-16 sm:justify-between md:flex-row md:space-y-0">
          <nav class="text-zinc-800 dark:text-zinc-100">
            <ul class="flex space-x-4 font-medium">
              <%= for %{to: to, label: label} <- header_links() do %>
                <li>
                  <.link
                    navigate={to}
                    class={if active?(@url, to), do: "text-cyan-500 dark:text-cyan-400", else: ""}
                  >
                    <%= label %>
                  </.link>
                </li>
              <% end %>
            </ul>
          </nav>
          <p class="text-center text-zinc-400 dark:text-zinc-500">
            © 2022 Florian Arens. All rights reserved.
          </p>
        </div>
      </div>
    </footer>
    """
  end

  attr :title, :string, required: true, doc: "The title."
  attr :logo, :string, required: true, doc: "The logo src."
  attr :description, :string, required: true, doc: "The description."
  attr :date_range, :string, required: true, doc: "The date range."

  def cv_item(assigns) do
    ~H"""
    <div class="flex space-x-6 pt-2">
      <img class="mt-2 inline-block h-8 w-8 rounded-full ring-2 ring-zinc-100" src={@logo} alt="logo" />
      <div class="flex w-full flex-col space-y-1">
        <p class="text-md font-medium text-zinc-800 dark:text-zinc-100">
          <%= @title %>
        </p>
        <div class="flex justify-between space-x-4">
          <div class="flex w-3/4 flex-col space-y-2 text-sm text-zinc-600 dark:text-zinc-400">
            <p><%= @description %></p>
          </div>
          <div class="self-end" role="tooltip" aria-label={@date_range} data-balloon-pos="up">
            <Heroicons.calendar_days class="h-5 w-5 text-zinc-600 dark:text-zinc-400" />
          </div>
        </div>
      </div>
    </div>
    """
  end

  attr :label, :string, required: true, doc: "The label to be displayed."

  slot :icon, doc: "The icon."
  slot :inner_block

  def cv_container(assigns) do
    ~H"""
    <div class="bg-zinc-200/30 flex flex-col space-y-3 rounded-xl px-6 py-4 dark:bg-zinc-800/30">
      <div class="text-md flex items-center space-x-4 font-medium">
        <%= render_slot(@icon) %>
        <p class="text-zinc-800 dark:text-zinc-100">
          <%= @label %>
        </p>
      </div>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :socket, :map, required: true, doc: "The socket."
  attr :article, :map, required: true, doc: "The article."

  def article_card(assigns) do
    ~H"""
    <.link
      navigate={Routes.blog_show_path(@socket, :show, Map.get(@article, :slug))}
      class="bg-zinc-200/30 group flex flex-col space-y-4 rounded-xl p-5 dark:bg-zinc-800/30"
    >
      <p class="border-zinc-700/50 w-2/4 border-l-4 pl-4 text-sm text-zinc-500">
        <%= Map.get(@article, :date) |> Utils.date_to_string() %>
      </p>

      <div class="flex flex-col space-y-2">
        <p class="font-medium text-zinc-800 dark:text-zinc-100">
          <%= Map.get(@article, :title) %>
        </p>
        <p class="text-zinc-600 dark:text-zinc-400">
          <%= Map.get(@article, :summary) %>
        </p>
        <div class="flex items-center pt-4 text-zinc-800 group-hover:text-cyan-500 dark:text-zinc-100 dark:group-hover:text-cyan-400">
          <p>Read article</p>
          <Heroicons.arrow_right solid class="ml-2 h-4 w-4" />
        </div>
      </div>
    </.link>
    """
  end

  attr :socket, :map, required: true, doc: "The socket."
  attr :articles, :list, required: true, doc: "A list of articles."

  def article_timeline(assigns) do
    ~H"""
    <div class="border-0 md:border-l md:border-zinc-300 md:dark:border-zinc-700/50">
      <div class="flex flex-col space-y-14">
        <%= for article <- @articles do %>
          <div
            to={"/blog/" <> Map.get(article, :slug)}
            link_type="live_redirect"
            class="flex flex-col space-y-4 md:flex-row md:space-x-2 md:space-y-0"
          >
            <p class="border-zinc-700/50 w-2/4 border-l-4 pl-4 text-sm text-zinc-500 md:ml-0 md:border-0 md:pl-10">
              <%= Map.get(article, :date) |> Utils.date_to_string() %>
            </p>

            <.link
              navigate={Routes.blog_show_path(@socket, :show, Map.get(article, :slug))}
              class="group flex flex-col space-y-2"
            >
              <p class="font-medium text-zinc-800 dark:text-zinc-100">
                <%= Map.get(article, :title) %>
              </p>
              <p class="text-zinc-600 dark:text-zinc-400">
                <%= Map.get(article, :summary) %>
              </p>
              <div class="flex items-center pt-4 text-zinc-800 group-hover:text-cyan-500 dark:text-zinc-100 dark:group-hover:text-cyan-400">
                <p>Read article</p>
                <Heroicons.arrow_right solid class="ml-2 h-4 w-4" />
              </div>
            </.link>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  attr :link, :string, required: true, doc: "The link to the project."
  attr :title, :string, required: true, doc: "The title of the project."
  attr :description, :string, required: true, doc: "The description of the project."
  attr :link_label, :string, required: true, doc: "The link label for the url."

  def project_card(assigns) do
    ~H"""
    <.link
      href={@link}
      target="_blank"
      class="bg-zinc-200/30 group flex w-full flex-col space-y-3 rounded-xl p-5 dark:bg-zinc-800/30 lg:w-80"
    >
      <p class="font-medium text-zinc-800 dark:text-zinc-100">
        <%= @title %>
      </p>
      <p class="text-zinc-600 dark:text-zinc-400">
        <%= @description %>
      </p>
      <div class="flex grow flex-col justify-end pt-4">
        <div class="flex items-center space-x-2 text-zinc-800 dark:text-zinc-100">
          <Heroicons.link
            solid
            class="h-5 w-5 group-hover:text-cyan-500 dark:group-hover:text-cyan-400"
          />
          <p class="group-hover:text-cyan-500 dark:group-hover:text-cyan-400">
            <%= @link_label %>
          </p>
        </div>
      </div>
    </.link>
    """
  end

  attr :class, :string, default: "", doc: "Additional classes to be added to the icon."

  def github_icon(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      class={"#{@class} icon icon-tabler icon-tabler-brand-github"}
      width="24"
      height="24"
      viewBox="0 0 24 24"
      stroke-width="2"
      stroke="currentColor"
      fill="none"
      stroke-linecap="round"
      stroke-linejoin="round"
    >
      <path stroke="none" d="M0 0h24v24H0z" fill="none" />
      <path d="M9 19c-4.3 1.4 -4.3 -2.5 -6 -3m12 5v-3.5c0 -1 .1 -1.4 -.5 -2c2.8 -.3 5.5 -1.4 5.5 -6a4.6 4.6 0 0 0 -1.3 -3.2a4.2 4.2 0 0 0 -.1 -3.2s-1.1 -.3 -3.5 1.3a12.3 12.3 0 0 0 -6.2 0c-2.4 -1.6 -3.5 -1.3 -3.5 -1.3a4.2 4.2 0 0 0 -.1 3.2a4.6 4.6 0 0 0 -1.3 3.2c0 4.6 2.7 5.7 5.5 6c-.6 .6 -.6 1.2 -.5 2v3.5" />
    </svg>
    """
  end

  attr :class, :string, default: "", doc: "Additional classes to be added to the icon."

  def linkedin_icon(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      class={"#{@class} icon icon-tabler icon-tabler-brand-linkedin"}
      width="24"
      height="24"
      viewBox="0 0 24 24"
      stroke-width="2"
      stroke="currentColor"
      fill="none"
      stroke-linecap="round"
      stroke-linejoin="round"
    >
      <path stroke="none" d="M0 0h24v24H0z" fill="none" />
      <rect x="4" y="4" width="16" height="16" rx="2" />
      <line x1="8" y1="11" x2="8" y2="16" />
      <line x1="8" y1="8" x2="8" y2="8.01" />
      <line x1="12" y1="16" x2="12" y2="11" />
      <path d="M16 16v-3a2 2 0 0 0 -4 0" />
    </svg>
    """
  end

  def theme_switch_light(assigns) do
    ~H"""
    <div class="ring-zinc-500/80 group flex h-8 w-8 cursor-pointer items-center justify-center rounded-full bg-zinc-800 ring-2 hover:ring-yellow-300">
      <Heroicons.sun solid class="h-6 w-6 text-zinc-100 group-hover:text-yellow-300" />
    </div>
    """
  end
end
