export default {
  mounted () {
    this.handleClick = (e) => {
      e.preventDefault()
      clearTimeout(this.timeout)

      const { value } = this.el.dataset
      const originalText = this.el.innerText

      const notice = this.el.dataset.notice || 'Copied!'

      navigator.clipboard.writeText(value).then(() => {
        this.el.innerText = notice
        this.timeout = setTimeout(() => { this.el.innerText = originalText }, 2000)
      }).catch(() => {
        this.el.innerText = 'Failed to copy'
        this.timeout = setTimeout(() => { this.el.innerText = originalText }, 2000)
      })
    }

    this.el.addEventListener('click', this.handleClick)
  },

  destroyed () {
    this.el.removeEventListener('click', this.handleClick)
    clearTimeout(this.timeout)
  }
}
