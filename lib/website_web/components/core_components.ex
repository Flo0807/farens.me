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
    %{label: "Light", theme: "light", icon: "hero-sun"},
    %{label: "Dark", theme: "dark", icon: "hero-moon"},
    %{label: "Night", theme: "night", icon: "hero-star"},
    %{label: "Sunset", theme: "sunset", icon: "hero-sun"},
    %{label: "Dracula", theme: "dracula", icon: "hero-paint-brush"}
  ]

  @doc """
  Renders a title.
  """
  attr :text, :string, required: true

  def title(assigns) do
    ~H"""
    <h1 class="text-base-content text-3xl font-bold md:text-4xl">
      {@text}
    </h1>
    """
  end

  @doc """
  Renders the page intro.
  """
  attr :label, :string, default: nil
  attr :title, :string, default: nil
  slot :inner_block

  def page_intro(assigns) do
    ~H"""
    <p :if={@label} class="text-base-content/40 mb-2 text-xs uppercase tracking-wider">
      {@label}
    </p>
    <.title :if={@title} text={@title} />
    <div
      :if={@inner_block != []}
      class="text-base-content/60 text-pretty mt-6 mb-10 leading-relaxed lg:w-2/3"
    >
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
    <nav aria-label="Main navigation" class="flex h-20">
      <div class="mx-auto flex w-full max-w-6xl items-center justify-between px-4">
        <.avatar />

        <div class={[
          "hidden items-center gap-1 sm:flex",
          "bg-base-200/80 rounded-box",
          "border-base-content/5 border",
          "px-1.5 py-1"
        ]}>
          <.link
            :for={%{label: label, to: to} <- main_navigation_links()}
            navigate={to}
            class={[
              "rounded-box px-4 py-2 text-sm font-medium",
              "transition-all duration-200",
              if(active?(@current_url, to),
                do: "text-primary bg-primary/10",
                else: "text-base-content hover:bg-base-content/5"
              )
            ]}
          >
            {label}
          </.link>
        </div>

        <button
          class="btn flex items-center font-semibold sm:hidden"
          onclick="mobile_navigation.showModal()"
        >
          <span>Menu</span>
          <.icon name="hero-bars-3" class="size-4" />
        </button>

        <.theme_switch />
      </div>
    </nav>
    """
  end

  def avatar(assigns) do
    ~H"""
    <.link
      navigate={~p"/"}
      class={[
        "group relative",
        "rounded-full",
        "ring-2 ring-transparent",
        "transition-all duration-300",
        "hover:ring-primary/20 hover:ring-offset-base-100 hover:ring-offset-2"
      ]}
    >
      <div class="size-10 overflow-hidden rounded-full">
        <img
          loading="lazy"
          src={~p"/images/me.jpg"}
          alt="Portrait of Florian"
          class="h-full w-full object-cover transition-transform duration-300 group-hover:scale-110"
        />
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
    <div
      id="theme_switch"
      phx-hook="ThemeSwitch"
      title="Change theme"
      class="dropdown dropdown-end"
    >
      <div
        tabindex="0"
        role="button"
        class={[
          "btn",
          "hover:bg-base-content/5",
          "transition-all duration-200",
          "border-base-content/5 border"
        ]}
      >
        <.icon name="hero-swatch" class="size-4" />
        <.icon name="hero-chevron-down" class="size-3 opacity-40" />
        <span class="sr-only">Switch theme</span>
      </div>
      <ul
        tabindex="0"
        class={[
          "dropdown-content menu",
          "mt-3 w-56 p-2",
          "bg-base-100/95 backdrop-blur-xl",
          "rounded-2xl",
          "border-base-content/5 border",
          "shadow-base-content/10 shadow-xl",
          "z-50"
        ]}
      >
        <li :for={%{label: label, theme: theme, icon: icon} <- @themes}>
          <button
            class={[
              "flex items-center gap-3 rounded-xl px-3 py-2.5",
              "transition-colors duration-150",
              "hover:bg-base-content/5"
            ]}
            phx-click={JS.dispatch("change-theme", detail: %{theme: theme})}
          >
            <.icon name={icon} class="size-4 opacity-60" />
            <span class="flex-1 text-left">{label}</span>
          </button>
        </li>
      </ul>
    </div>
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
    <dialog id="mobile_navigation" class="modal modal-bottom">
      <div class={[
        "modal-box rounded-t-3xl",
        "bg-base-100/95 backdrop-blur-xl",
        "border-base-content/5 border-t",
        "pb-safe"
      ]}>
        <div class="flex justify-center pb-4">
          <div class="bg-base-content/20 h-1.5 w-12 rounded-full" />
        </div>

        <form method="dialog" class="absolute top-4 right-4">
          <button class="btn btn-sm btn-circle btn-ghost">
            <.icon name="hero-x-mark" class="size-5" />
          </button>
        </form>

        <nav aria-label="Mobile navigation" class="flex flex-col gap-1 px-2 pb-4">
          <.link
            :for={%{label: label, to: to} <- main_navigation_links()}
            navigate={to}
            class={[
              "flex items-center gap-4 rounded-2xl px-4 py-4",
              "text-lg font-medium",
              "transition-all duration-200",
              "active:scale-[0.98]",
              "hover:bg-base-content/5"
            ]}
          >
            <span class="flex-1">{label}</span>
            <.icon name="hero-chevron-right" class="size-5 text-base-content/30" />
          </.link>
        </nav>

        <div class="border-base-content/5 border-t px-6 pt-4">
          <p class="text-base-content/40 mb-3 text-xs uppercase tracking-wider">Connect</p>
          <.contact_links
            class="flex gap-4"
            icon_class="size-6 text-base-content/50 hover:text-primary transition-colors fill-current"
          />
        </div>
      </div>
      <form method="dialog" class="modal-backdrop bg-base-content/50 backdrop-blur-sm">
        <button>close</button>
      </form>
    </dialog>
    """
  end

  @doc """
  Renders a footer.
  """
  attr :class, :string, default: nil
  attr :current_url, :string, required: true

  def footer(assigns) do
    ~H"""
    <footer class="border-base-content/5 relative mt-8 border-t md:mt-12">
      <div class="from-base-100 pointer-events-none absolute inset-x-0 -top-8 h-8 bg-gradient-to-t to-transparent md:-top-12 md:h-12" />

      <div class="mx-auto w-full max-w-6xl px-4 py-12 md:py-16">
        <div class="grid grid-cols-1 gap-8 md:grid-cols-3 md:gap-12">
          <div class="md:col-span-1">
            <.link navigate={~p"/"} class="group inline-flex items-center gap-3">
              <div class="ring-base-content/5 h-10 w-10 overflow-hidden rounded-full ring-2 transition-all duration-200 group-hover:ring-primary/20">
                <img src={~p"/images/me.jpg"} alt="Florian" class="h-full w-full object-cover" />
              </div>
              <span class="text-base-content font-semibold">Florian Arens</span>
            </.link>
            <p class="text-base-content/50 mt-4 max-w-xs text-sm">
              Software developer crafting modern web experiences with Elixir and Phoenix.
            </p>
          </div>

          <nav aria-label="Footer navigation" class="md:col-span-1">
            <p class="text-base-content/40 mb-4 text-xs font-semibold uppercase tracking-wider">
              Navigation
            </p>
            <div class="flex flex-col gap-2">
              <.link
                :for={%{label: label, to: to} <- main_navigation_links()}
                navigate={to}
                class={[
                  "text-base-content/60 text-sm transition-colors duration-150 hover:text-primary",
                  active?(@current_url, to) && "text-primary"
                ]}
              >
                {label}
              </.link>
            </div>
          </nav>

          <div class="md:col-span-1">
            <p class="text-base-content/40 mb-4 text-xs font-semibold uppercase tracking-wider">
              Connect
            </p>
            <.contact_links
              class="flex gap-3"
              icon_class="size-5 text-base-content/40 hover:text-primary transition-colors duration-150 fill-current"
            />
          </div>
        </div>

        <div class="border-base-content/5 mt-12 flex flex-col gap-4 border-t pt-6 md:flex-row md:items-center md:justify-between">
          <p class="text-base-content/30 text-xs">
            &copy; {Date.utc_today().year} Florian Arens. All rights reserved.
          </p>
          <nav class="flex gap-4" aria-label="Legal">
            <.link
              :for={%{label: label, to: to} <- secondary_navigation_links()}
              navigate={to}
              class="text-base-content/30 text-xs transition-colors duration-150 hover:text-base-content/60"
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
  attr :icon_class, :any, required: true

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
      <article class={[
        "group relative h-full",
        "rounded-2xl",
        "from-base-200 to-base-200/50 bg-gradient-to-b",
        "border-base-content/5 border",
        "p-6",
        "transition-all duration-300 ease-out",
        "hover:border-base-content/10",
        "hover:shadow-base-content/5 hover:shadow-lg",
        "hover:-translate-y-1"
      ]}>
        <div class="from-primary/5 to-secondary/5 absolute inset-0 rounded-2xl bg-gradient-to-br via-transparent opacity-0 transition-opacity duration-300 group-hover:opacity-100" />

        <div class="relative">
          <div class="flex items-start justify-between">
            <h2 class="text-base-content text-lg font-semibold transition-colors duration-200 group-hover:text-primary">
              {@title}
            </h2>
            <.icon
              name="hero-arrow-up-right"
              class={[
                "size-5 text-base-content/30",
                "transition-all duration-200",
                "group-hover:text-primary",
                "group-hover:translate-x-0.5 group-hover:-translate-y-0.5"
              ]}
            />
          </div>

          <p class="text-base-content/60 mt-3 text-sm leading-relaxed">
            {@description}
          </p>

          <div class="text-base-content/40 mt-4 flex items-center gap-2 text-sm">
            <.icon name="hero-link" class="size-4" />
            <span class="transition-colors duration-200 group-hover:text-primary group-hover:underline">
              {@link_label}
            </span>
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
    <.link id={@id} navigate={@link}>
      <article class={[
        "group relative h-full",
        "rounded-box",
        "from-base-200 to-base-200/50 bg-linear-to-br",
        "border-base-content/5 border",
        "p-6",
        "transition-all duration-300 ease-out",
        "hover:border-base-content/10",
        "hover:shadow-base-content/5 hover:shadow-lg",
        "hover:-translate-y-1",
        @class
      ]}>
        <div class="from-primary/5 to-secondary/5 bg-linear-to-br absolute inset-0 rounded-2xl via-transparent opacity-0 transition-opacity duration-300 group-hover:opacity-100" />

        <div class="relative flex h-full flex-col">
          <div class="text-base-content/50 flex items-center gap-3 text-xs font-medium">
            <time datetime={@date}>
              {Calendar.strftime(@date, "%b %d, %Y")}
            </time>
            <span class="bg-base-content/20 h-1 w-1 rounded-full" />
            <span>{@read_minutes} min read</span>
          </div>

          <h2 class={[
            "mt-4 text-lg font-semibold leading-snug",
            "text-base-content",
            "transition-colors duration-200",
            "group-hover:text-primary"
          ]}>
            {@title}
          </h2>

          <div :if={@tags != []} class="mt-3 flex flex-wrap gap-2">
            <span
              :for={tag <- @tags}
              class={[
                "inline-flex items-center",
                "px-2.5 py-0.5",
                "text-xs font-medium",
                "rounded-full",
                "bg-base-content/5 text-base-content/60",
                "transition-colors duration-200",
                "group-hover:bg-primary/10 group-hover:text-primary"
              ]}
            >
              {tag}
            </span>
          </div>

          <p class="text-base-content/70 line-clamp-3 mt-4 text-sm leading-relaxed">
            {@description}
          </p>

          <div class={[
            "mt-auto flex items-center gap-2 pt-6",
            "text-base-content/50 text-sm font-medium",
            "transition-all duration-200",
            "group-hover:text-primary group-hover:gap-3"
          ]}>
            <span>Read article</span>
            <.icon
              name="hero-arrow-right"
              class="size-4 transition-transform duration-200 group-hover:translate-x-1"
            />
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
    <section id={@id} class="space-y-4">
      <h2 class="text-base-content/40 text-sm font-semibold uppercase tracking-wider">
        Filter by topic
      </h2>

      <div class="flex flex-wrap gap-2">
        <button
          :for={tag <- @tags}
          phx-click="select-tag"
          phx-value-tag={tag}
          class={[
            "inline-flex items-center px-2.5 py-1",
            "text-xs font-medium",
            "rounded-full",
            "cursor-pointer border",
            "transition-all duration-200",
            "hover:scale-105 active:scale-100",
            if(String.downcase(tag) == @search_tag,
              do: ["bg-primary/10 text-primary border-primary/20", "shadow-primary/10 shadow-sm"],
              else: [
                "bg-base-200/50 text-base-content/60 border-base-content/5",
                "hover:bg-base-200 hover:text-base-content hover:border-base-content/10"
              ]
            )
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
  attr :class, :string, default: nil
  attr :is_root, :boolean, default: true

  def toc(assigns) do
    ~H"""
    <nav :if={@is_root} aria-label="Table of contents" class={["group", @class]}>
      <p class="text-base-content/40 mb-4 text-xs font-semibold uppercase tracking-wider">
        On this page
      </p>
      <ul class="space-y-1">
        <li :for={%{label: label, href: href, childs: childs} <- @headings}>
          <.link
            href={href}
            class={[
              "text-base-content/50 block py-1.5 text-sm",
              "hover:text-primary",
              "transition-colors duration-150",
              "border-l-2 border-transparent pl-3",
              "hover:border-primary/50"
            ]}
          >
            {label}
          </.link>
          <ul :if={childs != []} class="ml-3 space-y-1">
            <li :for={%{label: child_label, href: child_href} <- childs}>
              <.link
                href={child_href}
                class="text-base-content/40 block py-1 pl-3 text-xs transition-colors duration-150 hover:text-primary"
              >
                {child_label}
              </.link>
            </li>
          </ul>
        </li>
      </ul>
    </nav>
    <ul :if={!@is_root} class="ml-3 space-y-1">
      <li :for={%{label: label, href: href, childs: childs} <- @headings}>
        <.link
          href={href}
          class="text-base-content/40 block py-1 pl-3 text-xs transition-colors duration-150 hover:text-primary"
        >
          {label}
        </.link>
        <.toc :if={childs != []} headings={childs} is_root={false} />
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

  @doc """
  Renders a divider.
  """
  def divider(assigns) do
    ~H"""
    <div class="relative py-4">
      <div class="absolute inset-0 flex items-center">
        <div class="border-base-content/5 w-full border-t" />
      </div>
    </div>
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
