defmodule WebsiteWeb.Layouts do
  use WebsiteWeb, :html

  embed_templates "layouts/*"

  @doc """
  Renders the app layout.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :current_url, :string, required: true
  attr :main_class, :string, default: "pt-8 pb-4 md:pt-12 md:pb-6 lg:pt-16 lg:pb-8"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <div class="flex min-h-screen flex-col">
      <.live_component module={WebsiteWeb.SearchLive} id="global-search" />
      <a
        href="#main-content"
        class="sr-only focus:bg-base-100 focus:not-sr-only focus:absolute focus:z-50 focus:p-4"
      >Skip to content</a>
      <header>
        <.navbar current_url={@current_url} />
      </header>
      <main
        id="main-content"
        class={["relative mx-auto w-full max-w-3xl px-6", @main_class, "flex-1"]}
      >
        {render_slot(@inner_block)}
      </main>
      <.footer current_url={@current_url} />
    </div>
    """
  end
end
