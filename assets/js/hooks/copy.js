export default {
  mounted () {
    this.el.addEventListener('click', (e) => {
      e.preventDefault()

      const { value } = this.el.dataset
      const originalText = this.el.innerText

      const notice = this.el.dataset.notice || 'Copied!'

      navigator.clipboard.writeText(value).then(() => {
        this.el.innerText = notice
        setTimeout(() => { this.el.innerText = originalText }, 2000)
      })
    })
  }
}
