/* global IntersectionObserver, CSS */
export default {
  mounted () {
    const anchors = document.querySelectorAll('article .anchor[id]')
    if (anchors.length === 0) return

    this.tocLinks = this.el.querySelectorAll('a[href^="#"]')

    this.observer = new IntersectionObserver(
      (entries) => {
        let bestEntry = null

        for (const entry of entries) {
          if (!entry.isIntersecting) continue

          if (!bestEntry) {
            bestEntry = entry
            continue
          }

          const currentTop = entry.boundingClientRect.top
          const bestTop = bestEntry.boundingClientRect.top
          const currentIsAbove = currentTop < 0
          const bestIsAbove = bestTop < 0

          if (bestIsAbove && !currentIsAbove) {
            // Prefer entries that are at or below the top of the viewport
            bestEntry = entry
          } else if (currentIsAbove === bestIsAbove) {
            if (currentIsAbove) {
              // Both above viewport: choose the one closest to the top (greater top)
              if (currentTop > bestTop) bestEntry = entry
            } else {
              // Both in/under viewport: choose the one closest to the top (smaller top)
              if (currentTop < bestTop) bestEntry = entry
            }
          }
        }

        if (bestEntry) {
          const anchor = bestEntry.target.querySelector('.anchor[id]')
          if (anchor) this.activate(anchor.id)
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
    }

    const active = this.el.querySelector(`a[href="#${CSS.escape(id)}"]`)
    if (active) active.dataset.tocActive = ''
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
