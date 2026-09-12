const THEMES = new Set(['light', 'dark'])

export default {
  mounted () {
    this.handleThemeChange = (event) => {
      const requestedTheme = event.detail?.theme
      const theme = THEMES.has(requestedTheme) ? requestedTheme : 'dark'

      document.documentElement.setAttribute('data-theme', theme)
      document.documentElement.dataset.themePreference = theme
      this.syncThemeButtons(theme)

      try {
        window.localStorage.setItem('theme', theme)
      } catch (_error) {
        // Theme switching still works when storage is unavailable.
      }
    }

    this.handleSystemThemeChange = () => this.syncThemeButtons(document.documentElement.dataset.theme)
    window.addEventListener('theme-changed', this.handleSystemThemeChange)
    this.el.addEventListener('change-theme', this.handleThemeChange)
    this.syncThemeButtons(document.documentElement.dataset.theme)
  },

  updated () {
    this.syncThemeButtons(document.documentElement.dataset.theme)
  },

  destroyed () {
    window.removeEventListener('theme-changed', this.handleSystemThemeChange)
    this.el.removeEventListener('change-theme', this.handleThemeChange)
  },

  syncThemeButtons (theme) {
    this.el.querySelectorAll('[data-theme-value]').forEach((button) => {
      button.setAttribute('aria-pressed', String(button.dataset.themeValue === theme))
    })
  }
}
