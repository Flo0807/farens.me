defmodule WebsiteWeb.Components.ColorSchemeSwitch do
  use Phoenix.Component

  def color_scheme_switch(assigns) do
    ~H"""
    <button
      id={Ecto.UUID.generate()}
      phx-hook="ColorSchemeHook"
      class="ring-zinc-500/80 bg-white/90 group shadow-zinc-800/5 flex h-8 w-8 cursor-pointer items-center justify-center rounded-full shadow-lg ring-2 hover:ring-zinc-800 dark:bg-zinc-800 dark:hover:ring-yellow-300"
      aria-label="Toggle theme"
    >
      <Heroicons.sun
        solid
        class="color-scheme-light-icon hidden h-6 w-6 text-zinc-100 group-hover:text-yellow-300"
      />
      <Heroicons.moon
        solid
        class="color-scheme-dark-icon hidden h-6 w-6 text-zinc-500 group-hover:text-zinc-800"
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
