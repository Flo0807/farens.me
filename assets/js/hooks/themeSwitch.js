export default {
  mounted() {
    this.el.addEventListener('change-theme', (event) => {
      const theme = event.detail.theme;
      document.documentElement.setAttribute('data-theme', theme);
      localStorage.setItem('theme', theme);
    });
  },
}
