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
    %{label: "Dark", theme: "dark", icon: "hero-moon"}
  ]

  @doc """
  Renders a title.
  """
  attr :text, :string, required: true

  def title(assigns) do
    ~H"""
    <h1 class="text-base-content text-2xl font-semibold tracking-tight sm:text-3xl">
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
    <.section_label :if={@label} class="mb-2">
      {@label}
    </.section_label>
    <.title :if={@title} text={@title} />
    <div
      :if={@inner_block != []}
      class="text-base-content/70 text-pretty mt-6 mb-10 leading-relaxed"
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders a section label.
  """
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def section_label(assigns) do
    ~H"""
    <p class={["text-base-content/70 text-sm font-medium", @class]}>
      {render_slot(@inner_block)}
    </p>
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
    <dialog id={@id} class="modal" aria-labelledby={@header && "#{@id}-title"}>
      <div class="modal-box">
        <form method="dialog">
          <button
            class="btn btn-circle btn-ghost min-h-11 min-w-11 absolute top-2 right-2"
            aria-label="Close"
          >
            ✕
          </button>
        </form>
        <h2 :if={@header} id={"#{@id}-title"} class="text-base-content text-lg font-bold">
          {@header}
        </h2>
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
  attr :show_search, :boolean, default: true

  def navbar(assigns) do
    ~H"""
    <nav aria-label="Main navigation" class="mx-auto w-full max-w-3xl px-6 pt-6 sm:pt-10">
      <div class="flex flex-wrap items-center justify-between gap-x-4 gap-y-2">
        <.link navigate={~p"/"} class="min-h-11 inline-flex items-center font-semibold tracking-tight">
          Florian Arens
        </.link>
        <div class="flex items-center gap-1">
          <.search_button :if={@show_search} />
          <.theme_switch />
        </div>
        <div class="flex w-full flex-wrap items-center gap-x-6">
          <.link
            :for={%{label: label, to: to} <- main_navigation_links()}
            navigate={to}
            aria-current={active?(@current_url, to) && "page"}
            class={[
              "min-h-11 inline-flex items-center text-sm underline-offset-4 hover:underline",
              if(active?(@current_url, to), do: "font-medium underline", else: "text-base-content/70")
            ]}
          >
            {label}
          </.link>
        </div>
      </div>
    </nav>
    """
  end

  @doc false
  def avatar(assigns) do
    ~H"""
    <.link
      navigate={~p"/"}
      class="min-h-11 min-w-11 inline-flex items-center"
      aria-label="Florian Arens — Home"
    >
      <img
        src={~p"/images/me.jpg"}
        alt="Portrait of Florian"
        width="40"
        height="40"
        class="size-10 rounded-full object-cover"
      />
    </.link>
    """
  end

  @doc """
  Renders the search button.
  """
  def search_button(assigns) do
    ~H"""
    <button
      onclick="window.dispatchEvent(new CustomEvent('open-search'))"
      aria-label="Search articles"
      class="min-h-11 text-base-content/70 inline-flex items-center gap-2 px-3 text-sm underline-offset-4 hover:underline"
    >
      <.icon name="hero-magnifying-glass" class="size-4" />
      <span>Search</span>
    </button>
    """
  end

  @doc """
  Renders the theme switch.
  """
  def theme_switch(assigns) do
    assigns = assign(assigns, :themes, @themes)

    ~H"""
    <details id="theme_switch" phx-hook="ThemeSwitch" class="dropdown dropdown-end">
      <summary
        class="min-h-11 min-w-11 inline-flex cursor-pointer list-none items-center justify-center"
        aria-label="Switch theme"
      >
        <.icon name="hero-sun" class="size-4" />
      </summary>
      <ul class="dropdown-content menu border-base-content/15 bg-base-100 z-50 w-36 rounded-md border p-1">
        <li :for={%{label: label, theme: theme, icon: icon} <- @themes}>
          <button
            class="min-h-11 gap-2 rounded-sm"
            data-theme-value={theme}
            phx-click={
              JS.dispatch("change-theme", detail: %{theme: theme})
              |> JS.remove_attribute("open", to: "#theme_switch")
            }
          >
            <.icon name={icon} class="size-4" />
            {label}
          </button>
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
      <button data-share-web-share class="btn btn-ghost btn-square min-h-11 min-w-11 hidden">
        <.icon name="hero-share" />
        <span class="sr-only">Share</span>
      </button>
      <details id="share_dropdown" data-share-fallback class="dropdown dropdown-end hidden">
        <summary
          class="btn btn-ghost btn-square min-h-11 min-w-11"
          phx-click-away={JS.remove_attribute("open", to: "#share_dropdown")}
        >
          <.icon name="hero-share" />
          <span class="sr-only">Share</span>
        </summary>
        <ul class="menu dropdown-content bg-base-100 border-base-content/15 z-50 w-40 rounded-md border p-2">
          <li>
            <.link
              href={"https://x.com/intent/tweet?text=#{@title}&url=#{@link}&via=flo_arens"}
              target="_blank"
              rel="noopener noreferrer"
            >
              Share on X
            </.link>
          </li>
          <li>
            <button id="copy-blog-url" data-value={@link} phx-hook="Copy">
              Copy link
            </button>
          </li>
        </ul>
      </details>
    </div>
    """
  end

  @doc """
  Renders a footer.
  """
  attr :class, :string, default: nil
  attr :current_url, :string, required: true

  def footer(assigns) do
    ~H"""
    <footer class={["mx-auto mt-16 w-full max-w-3xl px-6 pb-8", @class]}>
      <div class="text-base-content/70 flex flex-col gap-2 pt-5 text-sm sm:flex-row sm:items-center sm:justify-between">
        <p>&copy; {Date.utc_today().year} Florian Arens</p>
        <nav class="flex flex-wrap gap-x-5" aria-label="Legal">
          <.link
            :for={%{label: label, to: to} <- secondary_navigation_links()}
            navigate={to}
            class="min-h-11 inline-flex items-center underline-offset-4 hover:underline"
          >
            {label}
          </.link>
        </nav>
      </div>
    </footer>
    """
  end

  @doc """
  Renders all contact links.
  """
  attr :class, :string, default: nil
  attr :icon_class, :any, default: nil

  def contact_links(assigns) do
    ~H"""
    <div class={["flex flex-wrap gap-x-5", @class]}>
      <.link
        :for={
          {label, href} <- [
            {"GitHub", "https://github.com/flo0807"},
            {"LinkedIn", "https://linkedin.com/in/florian-arens"},
            {"Bluesky", "https://bsky.app/profile/farens.me"},
            {"X", "https://x.com/flo_arens"},
            {"Email", "mailto:info@farens.me"}
          ]
        }
        href={href}
        class="min-h-11 decoration-base-content/30 inline-flex items-center text-sm underline underline-offset-4 hover:decoration-current"
      >
        {label}
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

  attr :heading_level, :atom, default: :h2

  def project_card(assigns) do
    ~H"""
    <article class="py-5">
      <.dynamic_tag tag_name={to_string(@heading_level)} class="text-base font-medium">
        <.link
          href={@link}
          target="_blank"
          rel="noopener noreferrer"
          class="min-h-11 decoration-base-content/30 inline-flex items-center underline underline-offset-4 hover:decoration-current"
        >
          {@title}
          <span class="sr-only"> (opens in a new tab)</span>
        </.link>
      </.dynamic_tag>
      <p class="text-base-content/70 mt-1 leading-relaxed">{@description}</p>
      <span class="text-base-content/70 mt-2 block text-sm">{@link_label}</span>
    </article>
    """
  end

  @doc """
  Renders a grid.
  """
  attr :class, :string, default: nil
  slot :inner_block

  def grid(assigns) do
    ~H"""
    <div class={@class}>
      {render_slot(@inner_block)}
    </div>
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
  attr :heading_level, :atom, default: :h2

  attr :compact, :boolean, default: false

  def blog_preview_card(assigns) do
    ~H"""
    <article id={@id} class={["py-5", @class]}>
      <div class="flex flex-col gap-1 sm:flex-row sm:items-baseline sm:justify-between sm:gap-6">
        <.dynamic_tag
          tag_name={to_string(@heading_level)}
          class="min-w-0 text-base font-medium leading-relaxed"
        >
          <.link
            navigate={@link}
            class="min-h-11 decoration-base-content/30 inline-flex items-center underline underline-offset-4 hover:decoration-current"
          >
            {@title}
          </.link>
        </.dynamic_tag>
        <time datetime={@date} class="text-base-content/70 shrink-0 text-sm">
          {Calendar.strftime(@date, "%b %d, %Y")}
        </time>
      </div>
      <p :if={!@compact} class="text-base-content/70 mt-2 leading-relaxed">{@description}</p>
      <div :if={!@compact} class="text-base-content/70 mt-3 flex flex-wrap gap-x-4 gap-y-1 text-sm">
        <span>{@read_minutes} min read</span>
        <span :for={tag <- @tags}>{tag}</span>
      </div>
    </article>
    """
  end

  @doc """
  Renders all blog tags.
  """
  attr :id, :string, default: nil
  attr :tags, :list, required: true
  attr :search_tag, :string, default: nil
  attr :select_event, :string, default: "select-tag"

  def blog_tags(assigns) do
    ~H"""
    <section id={@id} aria-label="Filter by topic">
      <.section_label>Filter by topic</.section_label>
      <div class="mt-2 flex flex-wrap gap-x-5">
        <button
          :for={tag <- @tags}
          phx-click={@select_event}
          phx-value-tag={tag}
          aria-pressed={to_string(String.downcase(tag) == @search_tag)}
          class={[
            "min-h-11 cursor-pointer text-sm underline-offset-4 hover:underline",
            if(String.downcase(tag) == @search_tag,
              do: "font-medium underline",
              else: "text-base-content/70"
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
  attr :id, :string, default: "toc"
  attr :headings, :list, required: true
  attr :class, :string, default: nil
  attr :is_root, :boolean, default: true
  attr :show_label, :boolean, default: true

  def toc(assigns) do
    ~H"""
    <nav
      :if={@is_root}
      id={@id}
      phx-hook="TocHighlight"
      aria-label="Table of contents"
      class={["group", "**:data-toc-active:text-primary **:data-toc-active:border-primary/50", @class]}
    >
      <.section_label :if={@show_label} class="mb-4">On this page</.section_label>
      <ul class="space-y-1">
        <li :for={%{label: label, href: href, childs: childs} <- @headings}>
          <.link
            href={href}
            class={[
              "text-base-content/70 min-h-11 flex items-center py-1.5 text-sm",
              "hover:text-primary",
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
                class="text-base-content/70 min-h-11 flex items-center py-1 pl-3 text-sm hover:text-primary"
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
          class="text-base-content/70 min-h-11 flex items-center py-1 pl-3 text-sm hover:text-primary"
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
