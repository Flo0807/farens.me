const ShareArticle = {
  mounted() {
    const shareButton = this.el.querySelector("#share_button");
    const shareDropdown = this.el.querySelector("#share_dropdown");
    const { title, url } = this.el.dataset;

    const shareData = {
      title: title,
      url: url,
    };

    if (navigator.share && navigator.canShare(shareData)) {
      shareButton.addEventListener("click", async () => {
        try {
          await navigator.share(shareData);
        } catch (err) {
          console.error("Error sharing:", err);
        }
      });
    } else {
      shareButton.classList.add("hidden");
      shareDropdown.classList.remove("hidden");
    }
  },
};

export default ShareArticle;
