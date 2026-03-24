/* global IntersectionObserver, CSS */
export default {
  mounted () {
    const anchors = document.querySelectorAll('article .anchor[id]')
    if (anchors.length === 0) return

    this.tocLinks = this.el.querySelectorAll('a[href^="#"]')

    this.observer = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          if (entry.isIntersecting) {
            const anchor = entry.target.querySelector('.anchor[id]')
            if (anchor) this.activate(anchor.id)
          }
        }
      },
      { rootMargin: '0px 0px -70% 0px', threshold: 0 }
    )

    for (const anchor of anchors) {
      this.observer.observe(anchor.parentElement)
    }

    this.activateFirstVisible(anchors)
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

  activateFirstVisible (anchors) {
    for (const anchor of anchors) {
      const rect = anchor.parentElement.getBoundingClientRect()
      if (rect.top >= 0 && rect.top < window.innerHeight * 0.3) {
        this.activate(anchor.id)
        return
      }
    }

    // If no heading is in the top 30%, activate the last one above the viewport
    let lastAbove = null
    for (const anchor of anchors) {
      if (anchor.parentElement.getBoundingClientRect().top < 0) {
        lastAbove = anchor
      }
    }
    if (lastAbove) this.activate(lastAbove.id)
  }
}
