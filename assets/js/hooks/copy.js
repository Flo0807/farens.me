const Copy = {
  mounted() {
    let { value } = this.el.dataset;

    this.el.addEventListener("click", (e) => {
      e.preventDefault();
      navigator.clipboard.writeText(value);
    });
  },
}

export default Copy;
