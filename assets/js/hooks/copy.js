export default {
  mounted () {
    const { value } = this.el.dataset

    this.el.addEventListener('click', (e) => {
      e.preventDefault()
      navigator.clipboard.writeText(value)
    })
  }
}
