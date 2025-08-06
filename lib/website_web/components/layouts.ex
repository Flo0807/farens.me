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
    <.mobile_navigation />
    <header>
      <.navbar current_url={@current_url} />
    </header>
    <main class="mx-auto my-8 w-full max-w-6xl px-4 md:my-12">
      {render_slot(@inner_block)}
    </main>
    <.footer current_url={@current_url} />
    """
  end
end
