defmodule WebsiteWeb.CoreComponents do
  @moduledoc """
  Provides core UI components.
  """
  use Gettext, backend: Website.Gettext
  use Phoenix.Component
  use WebsiteWeb, :verified_routes

  import WebsiteWeb.Icons

  alias Phoenix.LiveView.JS

  @themes [
    %{label: "Night", theme: "night", icon: "hero-star"},
    %{label: "Dark", theme: "dark", icon: "hero-moon"},
    %{label: "Sunset", theme: "sunset", icon: "hero-sun"},
    %{label: "Dracula", theme: "dracula", icon: "hero-paint-brush"}
  ]

  @doc """
  Renders a title.
  """
  attr :text, :string, required: true

  def title(assigns) do
    ~H"""
    <h1 class="text-3xl font-semibold">
      {@text}
    </h1>
    """
  end

  @doc """
  Renders the page intro.
  """
  attr :title, :string, default: nil
  slot :inner_block

  def page_intro(assigns) do
    ~H"""
    <.title :if={@title} text={@title} />
    <div :if={@inner_block != []} class="text-pretty my-8 leading-relaxed md:my-12 lg:w-2/3">
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders a modal.
  """
  attr :id, :string, required: true, doc: "the unique id of the modal"
  attr :header, :string, default: nil, doc: "the modal header"

  slot :inner_block, doc: "the inner block that renders the modal content"

  def modal(assigns) do
    ~H"""
    <dialog id={@id} class="modal">
      <div class="modal-box">
        <form method="dialog">
          <button class="btn btn-sm btn-circle btn-ghost absolute top-2 right-2">✕</button>
        </form>
        <h3 if={@header} class="text-base-content text-lg font-bold">
          {@header}
        </h3>
        {render_slot(@inner_block)}
      </div>
      <form method="dialog" class="modal-backdrop">
        <button>
          {gettext("close")}
        </button>
      </form>
    </dialog>
    """
  end

  @doc """
  Renders the navbar.
  """
  attr :current_url, :string, required: true

  def navbar(assigns) do
    ~H"""
    <nav class="flex h-20">
      <div class="mx-auto flex w-full max-w-6xl items-center justify-between px-4">
        <.avatar />

        <div class="rounded-btn bg-base-300 hidden space-x-2 px-4 py-2 sm:block">
          <.link
            :for={%{label: label, to: to} <- main_navigation_links()}
            navigate={to}
            class={["btn btn-sm", if(active?(@current_url, to), do: "btn-primary", else: "btn-ghost")]}
          >
            {label}
          </.link>
        </div>

        <div class="rounded-btn bg-base-300 block p-2 sm:hidden">
          <button
            class="btn-sm flex items-center font-semibold"
            onclick="mobile_navigation.showModal()"
          >
            <span>Menu</span>
          </button>
        </div>

        <.theme_switch />
      </div>
    </nav>
    """
  end

  def avatar(assigns) do
    ~H"""
    <.link navigate={~p"/"} class="avatar cursor-pointer">
      <div class="h-10 w-auto rounded-full">
        <img loading="lazy" src={~p"/images/me.jpg"} alt="Portrait of Florian" />
      </div>
    </.link>
    """
  end

  @doc """
  Renders the theme switch.
  """
  def theme_switch(assigns) do
    assigns = assign(assigns, :themes, @themes)

    ~H"""
    <details
      id="theme_switch"
      class="rounded-btn dropdown bg-base-300 dropdown-end p-2"
      phx-hook="ThemeSwitch"
    >
      <summary
        tabindex="0"
        aria-label="Switch theme"
        phx-click-away={JS.remove_attribute("open", to: "#theme_switch")}
        class="btn-sm flex items-center"
      >
        <.icon name="hero-swatch" />
        <span class="sr-only">Switch theme</span>
      </summary>
      <ul tabindex="0" class="dropdown-content z-[1] menu bg-base-300 rounded-box w-40 p-2 shadow">
        <li :for={%{label: label, theme: theme, icon: icon} <- @themes}>
          <div
            role="button"
            class="flex items-center space-x-2"
            phx-click={JS.dispatch("change-theme", detail: %{theme: theme})}
          >
            <.icon name={icon} class="h-4 w-4" />
            <span>{label}</span>
          </div>
        </li>
      </ul>
    </details>
    """
  end

  @doc """
  Renders the article share dropdown button.
  """
  attr :title, :string, required: true
  attr :link, :string, required: true

  def share_article_dropdown(assigns) do
    ~H"""
    <div id="share_container" phx-hook="WebShareApi" data-title={@title} data-url={@link}>
      <button data-share-web-share class="btn btn-ghost btn-sm btn-square hidden">
        <.icon name="hero-share" />
        <span class="sr-only">Share</span>
      </button>
      <details id="share_dropdown" data-share-fallback class="dropdown dropdown-end hidden">
        <summary
          class="btn btn-ghost btn-sm btn-square"
          phx-click-away={JS.remove_attribute("open", to: "#share_dropdown")}
        >
          <.icon name="hero-share" />
          <span class="sr-only">Share</span>
        </summary>
        <ul class="menu dropdown-content z-[1] bg-base-300 rounded-box w-40 p-2 shadow">
          <li>
            <.link
              href={"https://x.com/intent/tweet?text=#{@title}&url=#{@link}&via=flo_arens"}
              target="_blank"
            >
              Share on X
            </.link>
          </li>
          <li>
            <a id="copy-blog-url" role="button" data-value={@link} phx-hook="Copy">
              Copy link
            </a>
          </li>
        </ul>
      </details>
    </div>
    """
  end

  @doc """
  Renders the mobile navigation modal.
  """
  def mobile_navigation(assigns) do
    ~H"""
    <.modal id="mobile_navigation" header="Navigation">
      <nav class="mt-4 flex flex-col space-y-4">
        <.link :for={%{label: label, to: to} <- main_navigation_links()} navigate={to}>
          {label}
        </.link>
      </nav>
    </.modal>
    """
  end

  @doc """
  Renders a footer.
  """
  attr :class, :string, default: nil
  attr :current_url, :string, required: true

  def footer(assigns) do
    ~H"""
    <footer class="mx-auto w-full max-w-6xl px-4">
      <div class="bg-base-content h-px w-full opacity-20" />
      <div class="py-8 md:py-12">
        <div class="flex w-full flex-col flex-wrap justify-between gap-x-6 gap-y-6 md:flex-row">
          <nav class="">
            <p class="footer-title">Pages</p>
            <.link
              :for={%{label: label, to: to} <- main_navigation_links()}
              navigate={to}
              class={[
                "mr-4 font-semibold",
                if(active?(@current_url, to), do: "text-primary", else: "text-content")
              ]}
            >
              {label}
            </.link>
          </nav>
          <div>
            <p class="footer-title">Connect</p>
            <.contact_links
              class="flex space-x-4"
              icon_class="size-6 text-base-content/85 hover:text-base-content fill-current "
            />
          </div>
          <nav class="md:flex md:w-full md:justify-center">
            <p class="footer-title md:hidden">Legal</p>
            <.link
              :for={%{label: label, to: to} <- secondary_navigation_links()}
              navigate={to}
              class={[
                "mr-4 font-semibold md:text-sm md:opacity-60",
                if(active?(@current_url, to), do: "text-primary !opacity-100", else: "text-content")
              ]}
            >
              {label}
            </.link>
          </nav>
        </div>
      </div>
    </footer>
    """
  end

  @doc """
  Renders all contact links.
  """
  attr :class, :string, default: nil
  attr :icon_class, :string, required: true

  def contact_links(assigns) do
    ~H"""
    <div class={@class}>
      <.link href="https://github.com/flo0807" target="_blank">
        <span class="sr-only">GitHub</span>
        <.github_icon class={@icon_class} />
      </.link>
      <.link href="https://linkedin.com/in/florian-arens" target="_blank">
        <span class="sr-only">LinkedIn</span>
        <.linkedin_icon class={@icon_class} />
      </.link>
      <.link href="https://bsky.app/profile/farens.me" target="_blank">
        <span class="sr-only">Blueksy</span>
        <.bluesky_icon class={@icon_class} />
      </.link>
      <.link href="https://x.com/flo_arens" target="_blank">
        <span class="sr-only">X</span>
        <.x_icon class={@icon_class} />
      </.link>
      <.link href="mailto:info@farens.me">
        <span class="sr-only">Mail</span>
        <.mail_icon class={@icon_class} />
      </.link>
    </div>
    """
  end

  @doc """
  Renders a project card.
  """
  attr :title, :string, required: true
  attr :description, :string, required: true
  attr :link_label, :string, required: true
  attr :link, :string, required: true

  def project_card(assigns) do
    ~H"""
    <.link href={@link} target="_blank">
      <article class="card bg-base-200 group h-full w-full cursor-pointer transition-all hover:-translate-y-1">
        <div class="card-body">
          <h2 class="card-title text-pretty mb-4">
            {@title}
          </h2>
          <p class="text-pretty mb-4">
            {@description}
          </p>

          <div class="card-actions justify-end">
            <div class="flex items-center space-x-2">
              <.icon name="hero-link" class="text-content group-hover:text-primary" />
              <span class="text-content group-hover:text-primary group-hover:underline">
                {@link_label}
              </span>
            </div>
          </div>
        </div>
      </article>
    </.link>
    """
  end

  @doc """
  Renders a grid.
  """
  attr :class, :string, default: nil
  slot :inner_block

  def grid(assigns) do
    ~H"""
    <section class={["grid gap-5 md:grid-cols-2 lg:grid-cols-3", @class]}>
      {render_slot(@inner_block)}
    </section>
    """
  end

  @doc """
  Renders a blog preview card.
  """
  attr :id, :string, default: nil
  attr :link, :any, required: true
  attr :class, :string, default: nil
  attr :title, :string, required: true
  attr :description, :string, required: true
  attr :tags, :list, default: []
  attr :date, :any, required: true
  attr :read_minutes, :integer, required: true

  def blog_preview_card(assigns) do
    ~H"""
    <.link id={@id} navigate={@link} target="_blank">
      <article class={[
        "card bg-base-200 group h-full w-full cursor-pointer transition-all hover:-translate-y-1",
        @class
      ]}>
        <div class="card-body">
          <h2 class="card-title text-pretty mb-4">
            {@title}
          </h2>
          <div class="mb-4 flex w-fit items-center">
            <span class="text-xs font-semibold">
              {Calendar.strftime(@date, "%d %B %Y")}
            </span>
            <span class="bg-base-content mx-2 h-px w-4 flex-1 opacity-20" />
            <span class="text-xs font-semibold">
              {@read_minutes} min read
            </span>
          </div>
          <div :if={@tags != []} class="mb-4 flex flex-wrap gap-x-2 gap-y-2">
            <span :for={tag <- @tags} class="badge badge-neutral">{tag}</span>
          </div>
          <p class="text-pretty mb-4">
            {@description}
          </p>
          <div class="card-actions justify-end">
            <div class="flex items-center space-x-2">
              <span class="text-content group-hover:text-primary group-hover:underline">
                Read more
              </span>
              <.icon name="hero-arrow-right" class="text-content group-hover:text-primary" />
            </div>
          </div>
        </div>
      </article>
    </.link>
    """
  end

  @doc """
  Renders all blog tags.
  """
  attr :id, :string, default: nil
  attr :tags, :list, required: true
  attr :search_tag, :string, default: nil
  attr :select_event, :string

  def blog_tags(assigns) do
    ~H"""
    <section id={@id}>
      <h2 class="mb-4 text-xl font-semibold">
        Tags
      </h2>

      <div class="flex flex-wrap gap-2">
        <button
          :for={tag <- @tags}
          phx-click="select-tag"
          phx-value-tag={tag}
          class={[
            "badge badge-neutral transition-transform duration-100 hover:scale-105",
            String.downcase(tag) == @search_tag && "badge-primary"
          ]}
        >
          {tag}
        </button>
      </div>
    </section>
    """
  end

  @doc """
  Renders a table of contents from a list of headings.
  """
  attr :headings, :list, required: true
  attr :class, :string, default: "menu w-56 p-0 opacity-60"

  def toc(assigns) do
    ~H"""
    <ul class={@class}>
      <li :for={%{label: label, href: href, childs: childs} <- @headings}>
        <.link href={href}>
          {label}
        </.link>
        <.toc :if={childs != []} headings={childs} class="" />
      </li>
    </ul>
    """
  end

  @doc """
  Renders the Plausible analytics script.
  """
  def analytics(assigns) do
    ~H"""
    <script
      :if={Application.get_env(:website, :env) == :prod}
      defer
      data-domain="farens.me"
      src="https://plausible.farens.me/js/script.js"
    >
    </script>
    """
  end

  defp main_navigation_links do
    [
      %{label: "Home", to: ~p"/"},
      %{label: "About", to: ~p"/about"},
      %{label: "Blog", to: ~p"/blog"},
      %{label: "Projects", to: ~p"/projects"}
    ]
  end

  defp secondary_navigation_links do
    [
      %{label: "Legal Notice", to: ~p"/legal-notice"},
      %{label: "Privacy Policy", to: ~p"/privacy-policy"}
    ]
  end

  defp active?(current_url, to) do
    %{path: path} = URI.parse(current_url)

    if to == "/", do: path == to, else: String.starts_with?(path, to)
  end
end
