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

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <div class="flex min-h-screen flex-col">
      <.mobile_navigation />
      <header>
        <.navbar current_url={@current_url} />
      </header>
      <main class={[
        "relative mx-auto w-full max-w-6xl px-4",
        "pt-8 pb-4 md:pt-12 md:pb-6 lg:pt-16 lg:pb-8",
        "flex-1"
      ]}>
        {render_slot(@inner_block)}
      </main>
      <.footer current_url={@current_url} />
    </div>
    """
  end
end
