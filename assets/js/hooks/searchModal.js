const SearchModal = {
  mounted() {
    this.openSearch = () => {
      this.pushEventTo(this.el, 'open', {})
    }

    this.handleKeydown = (e) => {
      if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
        e.preventDefault()
        this.openSearch()
      }
    }

    this.handleOpenSearch = () => {
      this.openSearch()
    }

    document.addEventListener('keydown', this.handleKeydown)
    window.addEventListener('open-search', this.handleOpenSearch)

    this.handleEvent('open-search', () => {
      requestAnimationFrame(() => {
        const input = document.getElementById('search-input')
        if (input) {
          input.focus()
          input.select()
        }
      })
    })

    this.handleEvent('scroll-to-selected', ({ id }) => {
      const el = document.getElementById(id)
      if (el) el.scrollIntoView({ block: 'nearest' })
    })
  },

  destroyed() {
    document.removeEventListener('keydown', this.handleKeydown)
    window.removeEventListener('open-search', this.handleOpenSearch)
  }
}

export default SearchModal
