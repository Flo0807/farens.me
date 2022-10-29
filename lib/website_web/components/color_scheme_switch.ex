defmodule WebsiteWeb.Components.ColorSchemeSwitch do
  use Phoenix.Component

  def color_scheme_switch(assigns) do
    ~H"""
    <button
      id={Ecto.UUID.generate()}
      phx-hook="ColorSchemeHook"
      class="h-8 w-8 rounded-full ring-2 ring-zinc-500/80 hover:ring-zinc-800 dark:hover:ring-yellow-300 bg-white/90 dark:bg-zinc-800 flex items-center justify-center group cursor-pointer shadow-lg shadow-zinc-800/5"
      aria-label="Toggle theme"
    >
      <Heroicons.sun
        solid
        class="h-6 w-6 text-zinc-100 group-hover:text-yellow-300 color-scheme-light-icon hidden"
      />
      <Heroicons.moon
        solid
        class="h-6 w-6 text-zinc-500 group-hover:text-zinc-800 color-scheme-dark-icon hidden"
      />
    </button>
    """
  end

  def color_scheme_switch_js(assigns) do
    ~H"""
    <script>
      window.applyScheme = function(scheme) {
        if (scheme === "light") {
          document.documentElement.classList.remove('dark')
          document
            .querySelectorAll(".color-scheme-dark-icon")
            .forEach((el) => el.classList.remove("hidden"));
          document
            .querySelectorAll(".color-scheme-light-icon")
            .forEach((el) => el.classList.add("hidden"));
          localStorage.scheme = 'light'
        } else {
          document.documentElement.classList.add('dark')
          document
            .querySelectorAll(".color-scheme-dark-icon")
            .forEach((el) => el.classList.add("hidden"));
          document
            .querySelectorAll(".color-scheme-light-icon")
            .forEach((el) => el.classList.remove("hidden"));
          localStorage.scheme = 'dark'
        }
      };
      window.toggleScheme = function () {
        if (document.documentElement.classList.contains('dark')) {
          applyScheme("light")
        } else {
          applyScheme("dark")
        }
      }
      window.initScheme = function() {
        if (localStorage.scheme === 'dark' || (!('scheme' in localStorage) && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
          applyScheme("dark")
        } else {
          applyScheme("light")
        }
      }
      try {
        initScheme()
      } catch (_) {}
    </script>
    """
  end
end
