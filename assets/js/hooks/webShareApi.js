/**
 * WebShareApi Hook
 *
 * This hook provides functionality for sharing data using either the
 * Web Share API or a fallback sharing mechanism.
 *
 * Usage:
 * Add the `phx-hook="ShareArticle"` attribute to an element, and include
 * `data-title` and `data-url` attributes with the corresponding title and URL.
 *
 * Example:
 * <div phx-hook="ShareArticle" data-title="Article Title" data-url="https://example.com/article">
 *   <button data-share-web-share class="hidden">Share</button>
 *   <div data-share-fallback class="hidden">
 *     <!-- Fallback sharing options -->
 *   </div>
 * </div>
 */
const WebShareApi = {
  /**
   * Initializes the sharing functionality when the element is mounted.
   */
  mounted() {
    const { title, url } = this.el.dataset;
    const shareData = { title, url };

    this.initializeSharing(shareData);
  },
  /**
   * Sets up the appropriate sharing method based on browser support.
   * @param {Object} shareData - The data to be shared (title and URL).
   */
  initializeSharing(shareData) {
    const webShareButton = this.el.querySelector("button[data-share-web-share]");
    const fallbackShareElement = this.el.querySelector("[data-share-fallback]");

    if (navigator.share && navigator.canShare(shareData) && webShareButton) {
      this.setupWebSharing(webShareButton, shareData);
    } else if (fallbackShareElement) {
      this.setupFallbackSharing(fallbackShareElement);
    } else {
      console.error("Can not initialize sharing");
    }
  },
  /**
   * Configures the Web Share API sharing functionality.
   * @param {HTMLElement} webShareButton - The button element for sharing.
   * @param {Object} shareData - The data to be shared.
   */
  setupWebSharing(webShareButton, shareData) {
    webShareButton.classList.remove("hidden");
    webShareButton.addEventListener("click", async () => {
      try {
        await navigator.share(shareData);
      } catch (err) {
        console.error("Error sharing:", err);
      }
    });
  },
  /**
   * Sets up the fallback sharing mechanism when native sharing is not supported.
   * @param {HTMLElement} fallbackElement - The fallback sharing element to be displayed.
   */
  setupFallbackSharing(fallbackElement) {
    fallbackElement.classList.remove("hidden");
  }
};

export default WebShareApi;
