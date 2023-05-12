defmodule WebsiteWeb.CoreComponents do
  use WebsiteWeb, :verified_routes
  use Phoenix.Component

  import WebsiteWeb.Components.ColorSchemeSwitch

  alias Website.Utils

  @nav_links [
    %{to: "/", label: "Home"},
    %{to: "/about", label: "About"},
    %{to: "/blog", label: "Blog"},
    %{to: "/projects", label: "Projects"}
  ]

  attr(:url, :string, required: true, doc: "The current url.")
  attr(:nav_links, :list, default: @nav_links, doc: "A list of nav links to be rendered.")
  attr(:class, :string, default: nil, doc: "A class to be added to the header.")

  def header(assigns) do
    ~H"""
    <div x-data="{ mobile_menu: false }">
      <header class={["flex items-center justify-between", @class]}>
        <.link navigate="/" class="group shadow-zinc-800/5 shadow-lg">
          <img
            class="inline-block h-8 w-8 rounded-full ring-2 ring-white group-hover:ring-cyan-400"
            src="/images/me.jpg"
            alt="Portrait of Florian Arens"
          />
        </.link>
        <nav class="bg-white/90 ring-zinc-900/5 shadow-zinc-800/5 hidden rounded-full px-6 text-zinc-800 shadow-lg ring-1 dark:ring-white/10 dark:bg-zinc-800 dark:text-zinc-100 md:block">
          <ul class="flex space-x-6 font-medium">
            <li
              :for={%{to: to, label: label} <- @nav_links}
              class={[
                "relative px-3 py-2",
                if(active?(@url, to),
                  do: "text-cyan-500 dark:text-cyan-400",
                  else: "hover:text-cyan-500 hover:dark:text-cyan-400"
                )
              ]}
            >
              <.link navigate={to}>
                <%= label %>
              </.link>
              <span
                :if={active?(@url, to)}
                class="from-cyan-400/0 via-cyan-500/80 to-cyan-500/0 absolute inset-x-1 -bottom-px h-px bg-gradient-to-r dark:via-cyan-400/80 dark:to-cyan-400/0"
              >
              </span>
            </li>
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

        <.mobile_nav />
      </header>
    </div>
    """
  end

  attr(:nav_links, :list, default: @nav_links, doc: "A list of nav links to be rendered.")

  def mobile_nav(assigns) do
    ~H"""
    <div x-show="mobile_menu" @keydown.escape.window="mobile_menu = false">
      <div class="bg-zinc-900/80 fixed inset-0 z-50 transition-opacity" />

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
                :for={%{to: to, label: label} <- @nav_links}
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

  defp active?(current, to) do
    %{path: path} = URI.parse(current)

    if to == "/", do: path == to, else: String.starts_with?(path, to)
  end

  attr(:class, :string, default: nil, doc: "Additional classes to be added to the footer.")
  attr(:url, :string, required: true, doc: "The current url.")
  attr(:nav_links, :list, default: @nav_links, doc: "A list of nav links to be rendered.")

  def footer(assigns) do
    ~H"""
    <footer class={["border-t border-zinc-300 dark:border-zinc-700", @class]}>
      <div class="flex flex-col items-center space-y-2 sm:justify-between md:flex-row md:space-y-0">
        <nav class="text-zinc-800 dark:text-zinc-100">
          <ul class="flex space-x-4 font-medium">
            <li :for={%{to: to, label: label} <- @nav_links}>
              <.link
                navigate={to}
                class={if active?(@url, to), do: "text-cyan-500 dark:text-cyan-400", else: ""}
              >
                <%= label %>
              </.link>
            </li>
          </ul>
        </nav>
        <p class="text-center text-zinc-400 dark:text-zinc-500">
          © 2022 Florian Arens. All rights reserved.
        </p>
      </div>
    </footer>
    """
  end

  attr(:socket, :map, required: true, doc: "The socket.")
  attr(:article, :map, required: true, doc: "The article.")

  def article_card(assigns) do
    ~H"""
    <.link
      navigate={~p"/blog/#{Map.get(@article, :slug)}"}
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

  attr(:articles, :list, required: true, doc: "A list of articles.")

  def article_timeline(assigns) do
    ~H"""
    <div class="border-0 md:border-l md:border-zinc-300 md:dark:border-zinc-700/50">
      <div class="flex flex-col space-y-14">
        <div
          :for={article <- @articles}
          to={"/blog/" <> Map.get(article, :slug)}
          link_type="live_redirect"
          class="flex flex-col space-y-4 md:flex-row md:space-x-2 md:space-y-0"
        >
          <p class="border-zinc-700/50 w-2/4 border-l-4 pl-4 text-sm text-zinc-500 md:ml-0 md:border-0 md:pl-10">
            <%= Map.get(article, :date) |> Utils.date_to_string() %>
          </p>

          <.link navigate={~p"/blog/#{Map.get(article, :slug)}"} class="group flex flex-col space-y-2">
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
      </div>
    </div>
    """
  end

  attr(:link, :string, required: true, doc: "The link to the project.")
  attr(:title, :string, required: true, doc: "The title of the project.")
  attr(:description, :string, required: true, doc: "The description of the project.")
  attr(:link_label, :string, required: true, doc: "The link label for the url.")

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

  attr(:class, :string, default: nil, doc: "Additional classes to be added to the icon.")

  def github_icon(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 64 64"
      width="32px"
      height="32px"
      class={@class}
    >
      <path d="M32 6C17.641 6 6 17.641 6 32c0 12.277 8.512 22.56 19.955 25.286-.592-.141-1.179-.299-1.755-.479V50.85c0 0-.975.325-2.275.325-3.637 0-5.148-3.245-5.525-4.875-.229-.993-.827-1.934-1.469-2.509-.767-.684-1.126-.686-1.131-.92-.01-.491.658-.471.975-.471 1.625 0 2.857 1.729 3.429 2.623 1.417 2.207 2.938 2.577 3.721 2.577.975 0 1.817-.146 2.397-.426.268-1.888 1.108-3.57 2.478-4.774-6.097-1.219-10.4-4.716-10.4-10.4 0-2.928 1.175-5.619 3.133-7.792C19.333 23.641 19 22.494 19 20.625c0-1.235.086-2.751.65-4.225 0 0 3.708.026 7.205 3.338C28.469 19.268 30.196 19 32 19s3.531.268 5.145.738c3.497-3.312 7.205-3.338 7.205-3.338.567 1.474.65 2.99.65 4.225 0 2.015-.268 3.19-.432 3.697C46.466 26.475 47.6 29.124 47.6 32c0 5.684-4.303 9.181-10.4 10.4 1.628 1.43 2.6 3.513 2.6 5.85v8.557c-.576.181-1.162.338-1.755.479C49.488 54.56 58 44.277 58 32 58 17.641 46.359 6 32 6zM33.813 57.93C33.214 57.972 32.61 58 32 58 32.61 58 33.213 57.971 33.813 57.93zM37.786 57.346c-1.164.265-2.357.451-3.575.554C35.429 57.797 36.622 57.61 37.786 57.346zM32 58c-.61 0-1.214-.028-1.813-.07C30.787 57.971 31.39 58 32 58zM29.788 57.9c-1.217-.103-2.411-.289-3.574-.554C27.378 57.61 28.571 57.797 29.788 57.9z" />
    </svg>
    """
  end

  attr(:class, :string, default: nil, doc: "Additional classes to be added to the icon.")

  def linkedin_icon(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 50 50"
      width="32px"
      height="32px"
      class={@class}
    >
      <path d="M41,4H9C6.24,4,4,6.24,4,9v32c0,2.76,2.24,5,5,5h32c2.76,0,5-2.24,5-5V9C46,6.24,43.76,4,41,4z M17,20v19h-6V20H17z M11,14.47c0-1.4,1.2-2.47,3-2.47s2.93,1.07,3,2.47c0,1.4-1.12,2.53-3,2.53C12.2,17,11,15.87,11,14.47z M39,39h-6c0,0,0-9.26,0-10 c0-2-1-4-3.5-4.04h-0.08C27,24.96,26,27.02,26,29c0,0.91,0,10,0,10h-6V20h6v2.56c0,0,1.93-2.56,5.81-2.56 c3.97,0,7.19,2.73,7.19,8.26V39z" />
    </svg>
    """
  end

  attr(:class, :string, default: nil, doc: "Additional classes to be added to the icon.")

  def twitter_icon(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 50 50"
      width="32px"
      height="32px"
      class={@class}
    >
      <path d="M 50.0625 10.4375 C 48.214844 11.257813 46.234375 11.808594 44.152344 12.058594 C 46.277344 10.785156 47.910156 8.769531 48.675781 6.371094 C 46.691406 7.546875 44.484375 8.402344 42.144531 8.863281 C 40.269531 6.863281 37.597656 5.617188 34.640625 5.617188 C 28.960938 5.617188 24.355469 10.21875 24.355469 15.898438 C 24.355469 16.703125 24.449219 17.488281 24.625 18.242188 C 16.078125 17.8125 8.503906 13.71875 3.429688 7.496094 C 2.542969 9.019531 2.039063 10.785156 2.039063 12.667969 C 2.039063 16.234375 3.851563 19.382813 6.613281 21.230469 C 4.925781 21.175781 3.339844 20.710938 1.953125 19.941406 C 1.953125 19.984375 1.953125 20.027344 1.953125 20.070313 C 1.953125 25.054688 5.5 29.207031 10.199219 30.15625 C 9.339844 30.390625 8.429688 30.515625 7.492188 30.515625 C 6.828125 30.515625 6.183594 30.453125 5.554688 30.328125 C 6.867188 34.410156 10.664063 37.390625 15.160156 37.472656 C 11.644531 40.230469 7.210938 41.871094 2.390625 41.871094 C 1.558594 41.871094 0.742188 41.824219 -0.0585938 41.726563 C 4.488281 44.648438 9.894531 46.347656 15.703125 46.347656 C 34.617188 46.347656 44.960938 30.679688 44.960938 17.09375 C 44.960938 16.648438 44.949219 16.199219 44.933594 15.761719 C 46.941406 14.3125 48.683594 12.5 50.0625 10.4375 Z" />
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
