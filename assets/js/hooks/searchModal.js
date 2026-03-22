const SearchModal = {
  mounted() {
    this.isOpen = false
    this.previouslyFocused = null

    this.openSearch = () => {
      this.pushEventTo(this.el, 'open', {})
    }

    this.handleKeydown = (e) => {
      if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
        e.preventDefault()
        if (this.isOpen) {
          this.pushEventTo(this.el, 'close', {})
        } else {
          this.openSearch()
        }
      }
    }

    // Used by the search button in core_components.ex which dispatches
    // a CustomEvent('open-search') via window.dispatchEvent().
    this.handleOpenSearch = () => {
      this.openSearch()
    }

    this.selectedIndex = 0

    this.handleModalKeydown = (e) => {
      const results = this.el.querySelectorAll('[role="option"]')
      const count = results.length

      if (e.key === 'Tab') {
        // Focus trap
        const focusableSelectors = 'a[href], button:not([disabled]), input:not([disabled]), textarea:not([disabled]), select:not([disabled]), [tabindex]:not([tabindex="-1"])'
        const focusableElements = Array.from(this.el.querySelectorAll(focusableSelectors))
        if (focusableElements.length === 0) return

        const firstFocusable = focusableElements[0]
        const lastFocusable = focusableElements[focusableElements.length - 1]

        if (e.shiftKey) {
          if (document.activeElement === firstFocusable) {
            e.preventDefault()
            lastFocusable.focus()
          }
        } else {
          if (document.activeElement === lastFocusable) {
            e.preventDefault()
            firstFocusable.focus()
          }
        }
        return
      }

      if (e.key === 'ArrowDown' && count > 0) {
        e.preventDefault()
        this.selectedIndex = Math.min(this.selectedIndex + 1, count - 1)
        this.updateSelection(results)
        return
      }

      if (e.key === 'ArrowUp' && count > 0) {
        e.preventDefault()
        this.selectedIndex = Math.max(this.selectedIndex - 1, 0)
        this.updateSelection(results)
        return
      }

      if (e.key === 'Enter' && count > 0) {
        e.preventDefault()
        const selected = results[this.selectedIndex]
        if (selected) {
          const slug = selected.getAttribute('phx-value-slug')
          if (slug) this.pushEventTo(this.el, 'navigate', { slug })
        }
        return
      }
    }

    this.updateSelection = (results) => {
      results.forEach((el, i) => {
        const isSelected = i === this.selectedIndex
        el.setAttribute('aria-selected', String(isSelected))
        el.classList.toggle('bg-primary/10', isSelected)
        el.classList.toggle('hover:bg-base-content/5', !isSelected)

        const title = el.querySelector('.font-medium')
        if (title) {
          title.classList.toggle('text-primary', isSelected)
          title.classList.toggle('text-base-content', !isSelected)
        }
      })

      // Update aria-activedescendant on input
      const input = document.getElementById('search-input')
      if (input && results.length > 0) {
        input.setAttribute('aria-activedescendant', `search-result-${this.selectedIndex}`)
      }

      // Scroll into view
      const selected = results[this.selectedIndex]
      if (selected) selected.scrollIntoView({ block: 'nearest' })
    }

    document.addEventListener('keydown', this.handleKeydown)
    window.addEventListener('open-search', this.handleOpenSearch)

    this.handleEvent('open-search', () => {
      this.isOpen = true
      this.selectedIndex = 0
      this.previouslyFocused = document.activeElement

      this.el.addEventListener('keydown', this.handleModalKeydown)

      requestAnimationFrame(() => {
        requestAnimationFrame(() => {
          const input = document.getElementById('search-input')
          if (input) {
            input.focus()
            input.select()
          }
        })
      })
    })

    this.handleEvent('close-search', () => {
      this.closeModal()
    })

    this.handleEvent('scroll-to-selected', ({ id }) => {
      const el = document.getElementById(id)
      if (el) el.scrollIntoView({ block: 'nearest' })
    })
  },

  closeModal() {
    this.el.removeEventListener('keydown', this.handleModalKeydown)
    this.isOpen = false

    if (this.previouslyFocused && typeof this.previouslyFocused.focus === 'function') {
      this.previouslyFocused.focus()
      this.previouslyFocused = null
    }
  },

  destroyed() {
    document.removeEventListener('keydown', this.handleKeydown)
    window.removeEventListener('open-search', this.handleOpenSearch)
    this.closeModal()
  }
}

export default SearchModal
