/* global IntersectionObserver, CSS */
export default {
  mounted () {
    const headings = document.querySelectorAll('.prose-article :is(h1, h2, h3, h4, h5, h6)[id]')
    if (headings.length === 0) return

    this.tocLinks = this.el.querySelectorAll('a[href^="#"]')

    this.observer = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          if (entry.isIntersecting) {
            this.activate(entry.target.id)
          }
        }
      },
      { rootMargin: '0px 0px -70% 0px', threshold: 0 }
    )

    for (const heading of headings) {
      this.observer.observe(heading)
    }

    this.activateFirstVisible(headings)
  },

  destroyed () {
    if (this.observer) this.observer.disconnect()
  },

  activate (id) {
    for (const link of this.tocLinks) {
      delete link.dataset.tocActive
      link.removeAttribute('aria-current')
    }

    const active = this.el.querySelector(`a[href="#${CSS.escape(id)}"]`)
    if (active) {
      active.dataset.tocActive = ''
      active.setAttribute('aria-current', 'location')
    }
  },

  activateFirstVisible (headings) {
    for (const heading of headings) {
      const rect = heading.getBoundingClientRect()
      if (rect.top >= 0 && rect.top < window.innerHeight * 0.3) {
        this.activate(heading.id)
        return
      }
    }

    // If no heading is in the top 30%, activate the last one above the viewport
    let lastAbove = null
    for (const heading of headings) {
      if (heading.getBoundingClientRect().top < 0) {
        lastAbove = heading
      }
    }
    if (lastAbove) this.activate(lastAbove.id)
  }
}
