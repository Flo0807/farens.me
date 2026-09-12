(() => {
  const supportedThemes = new Set(['light', 'dark'])
  const prefersDark = window.matchMedia('(prefers-color-scheme: dark)')
  let storedTheme = null

  try {
    storedTheme = window.localStorage.getItem('theme')
  } catch (_error) {
    // Use the system preference when browser storage is unavailable.
  }

  const theme = storedTheme === null
    ? (prefersDark.matches ? 'dark' : 'light')
    : (supportedThemes.has(storedTheme) ? storedTheme : 'dark')

  document.documentElement.setAttribute('data-theme', theme)
  document.documentElement.dataset.themePreference = storedTheme === null ? 'system' : theme

  if (storedTheme !== null && !supportedThemes.has(storedTheme)) {
    try {
      window.localStorage.setItem('theme', 'dark')
    } catch (_error) {
      // The selected theme is already applied for this page.
    }
  }

  if (storedTheme === null) {
    prefersDark.addEventListener('change', (event) => {
      if (document.documentElement.dataset.themePreference !== 'system') return

      document.documentElement.setAttribute(
        'data-theme',
        event.matches ? 'dark' : 'light'
      )
      window.dispatchEvent(new window.Event('theme-changed'))
    })
  }
})()
