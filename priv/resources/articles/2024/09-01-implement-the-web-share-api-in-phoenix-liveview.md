%{
  slug: "implement-the-web-share-api-in-phoenix-liveview",
  title: "Implement the Web Share API in Phoenix LiveView",
  description: "Learn how to implement the Web Share API in your Phoenix LiveView application. This article will show you how to create a custom Phoenix LiveView hook to seamlessly share content, improve the user experience, and increase engagement.",
  published: true,
  tags: ["LiveView", "Phoenix", "Web Share API"]
}
---
Learn how to implement the Web Share API in your Phoenix LiveView application. This article will show you how to create a custom Phoenix LiveView hook to seamlessly share content, improve the user experience, and increase engagement.

## Introduction

The Web Share API enables web applications to call the native sharing capabilities of the device, allowing users to share content with their favorite applications. This can greatly enhance the user experience by providing a seamless way to share content directly from the web application.

In this article, we will explore how to integrate the Web Share API into a Phoenix LiveView application. We will create a custom Phoenix hook to handle the sharing functionality and demonstrate how to use it. At the end of this article, you will have a working example of how to use the Web Share API to improve user engagement in your Phoenix LiveView application.

We assume that you have already created a new Phoenix project or have an existing project to which you want to add the Web Share API.

## Problem

If you have content like blog articles on your website, you want to make it easy for users to share your content with others. You could add a "Share" button to your articles that copies the link to the clipboard. But this is not very user friendly because users have to manually paste the link into the application they want to share your article with. You start thinking about adding a "Share" dropdown to your articles that lists specific apps for the user to choose from, e.g. Reddit, X, etc. But this requires you to maintain that list of apps and their corresponding share URLs.

Fortunately, there is a better solution: the **Web Share API**! It allows you to use the device's native sharing capabilities to share your content.

## About the Web Share API

The Web Share API is a JavaScript API that enables web applications to share content with the user's device. It provides a way to share text, URLs, and other types of content with the user's favorite applications. You have probably used the Web Share API when you shared a link on your phone. It's the little pop-up that asks you which app you want to share the link with. We can also use this API in our LiveView applications to make it easier for users to share our content, such as our blog posts.

You can learn more about the Web Share API on [the MDN Web Docs](https://developer.mozilla.org/en-US/docs/Web/API/Web_Share_API).

## Implementation

In the following sections, we will create a new LiveView hook that will handle the Web Share API. We will then add the hook to our LiveView to invoke it when the user clicks a Share button.

### Setting up the Hook

To integrate the Web Share API into our LiveView application, we need to create a hook. A Phoenix LiveView hook is a way to add custom JavaScript functionality to your LiveView pages. You can learn more about hooks in the [Phoenix LiveView documentation](https://hexdocs.pm/phoenix_live_view/js-interop.html#client-hooks-via-phx-hook).

We need to create a hook because we need to write some client-side JavaScript to use the Web Share API. We create a new file `assets/js/hooks/webShareApi.js` and add the following boilerplate code to it:

```javascript
const WebShareApi = {
  mounted() {
    console.log("WebShareApi mounted");
  }
}

export default WebShareApi
```

This is a very simple hook that logs to the console when mounted.

### Add the Hook to our Project

To make the hook available to our LiveView, we need to add it to our project. We do this by adding the hook to the `assets/js/app.js` file.

```javascript
// Import the WebShareApi hook
import WebShareApi from "./hooks/webShareApi"

// Add the WebShareApi hook to a JavaScript object
const Hooks = {
  WebShareApi
}

// Create a new LiveSocket instance and pass in the Hooks object
let liveSocket = new LiveSocket("/live", Socket, { params: { _csrf_token: csrfToken }, hooks: Hooks })
```

You are now ready to call the `WebShareApi` hook in your LiveView application.

### Calling the Hook in your LiveView

We will call the `WebShareApi` hook from our markup to see if everything works. Let's add a new component `share_article.ex` to our `core_components.ex` file. We will use this component to share blog articles, but you can use it for other things as well.

```elixir
attr :title, :string, required: true
attr :link, :string, required: true

def share_article(assigns) do
  ~H"""
  <div id="share-article" phx-hook="WebShareApi" data-title={@title} data-url={@link}>
  </div>
  """
end
```

As you can see, we pass in the title and link of the blog article to the component and add these values to the dataset of the `share-article` div.

Add this component to your LiveView page and you will notice that the `WebShareApi` hook is called by looking at the "WebShareApi mounted" log in your browser's console.

### Add Functionality to the Hook

We now begin to add the actual functionality to the `WebShareApi` hook.

```javascript
const WebShareApi = {
  mounted() {
    console.log("WebShareApi mounted")

    const { title, url } = this.el.dataset;
    const shareData = { title, url };

    this.initializeSharing(shareData);
  },
  initializeSharing(shareData) {
    console.log("initializeSharing", shareData)
  }
}

export default WebShareApi
```

Obviously, we need the title and URL of the article to share. We extract these values from the dataset of the `share-article` div. Note that we have already added these values to the dataset in the previous step. Next, we want to initialize the sharing functionality. We do this by calling the `initializeSharing` method and passing in the `shareData` object that contains the title and URL of the article.

You should see the `initializeSharing` method called in the console when you reload the page.

In the `initializeSharing` method we will now check if the Web Share API is supported by the browser. If it is, we set up the sharing functionality. If not, we set up a fallback sharing functionality.

```javascript
const WebShareApi = {
  mounted() {
    ...
  },
  initializeSharing(shareData) {
    console.log("initializeSharing", shareData)

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
  setupWebSharing(webShareButton, shareData) {
    console.log("Web Share API is supported")
  },
  setupFallbackSharing(webShareButton, fallbackElement) {
    console.log("Web Share API is not supported")
  }
}

export default WebShareApi
```

Note that we are trying to find a web share button and a fallback element in the markup by looking for the `data-share-web-share` and `data-share-fallback` attributes. Let's add those attributes to our elements.

```elixir
<div id="share-article" phx-hook="WebShareApi" data-title={@title} data-url={@link}>
  <button data-share-web-share class="hidden">Share</button>
  <div data-share-fallback class="hidden"><%= @link %></div>
</div>
```

The button is used to trigger the Web Share API and the fallback element is used to display a fallback sharing mechanism. We have not used a button for the fallback sharing mechanism because the fallback mechanism can be anything. For example, you may want to display a text with the link to the article or implement a copy to clipboard button. Our goal here is to be as flexible as possible.

By default, we will hide the button and the fallback element. We will show the button if the Web Share API is supported, and the fallback element if it is not.

We can start implementing the actual sharing functionality for the Web Share API by adding the following to our `WebShareApi` hook:

```javascript
const WebShareApi = {
  mounted() {
    ...
  },
  initializeSharing(shareData) {
    ...
  },
  setupWebSharing(webShareButton, shareData) {
    console.log("Web Share API is supported")

    webShareButton.classList.remove("hidden");
    webShareButton.addEventListener("click", async () => {
      try {
        await navigator.share(shareData);
      } catch (err) {
        console.error("Error sharing:", err);
      }
    });
  }
}

export default WebShareApi
```

First, we remove the `hidden` class from the web share button. This makes the button visible to the user. We then add an event listener to the button to handle the click event. When the button is clicked, the `navigator#share` method is called. This will share the content with the user's device. Note that we have already checked for Web Share API support in the `initializeSharing` method.

We wrap the `navigator.share` call in a `try/catch` block to handle any errors that may occur. Errors can occur if the user cancels the sharing dialog or if the sharing fails for some other reason. We log the error to the console.

It is important to note that the Web Share API is only available in secure contexts (HTTPS).

We now set up the fallback sharing mechanism by adding the following to our `WebShareApi` hook:

```javascript
const WebShareApi = {
  mounted() {
    ...
  },
  initializeSharing(shareData) {
    ...
  },
  setupWebSharing(webShareButton, shareData) {
    ...
  },
  setupFallbackSharing(webShareButton, fallbackElement) {
    fallbackElement.classList.remove("hidden");
  }
}

export default WebShareApi
```

The fallback mechanism is as simple as removing the `hidden` class from the fallback element. This makes the fallback element visible to the user.

The complete `WebShareApi` hook should now look like this:

```javascript
// assets/js/hooks/webShareApi.js
const WebShareApi = {
  mounted() {
    const { title, url } = this.el.dataset;
    const shareData = { title, url };

    this.initializeSharing(shareData);
  },
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
  setupFallbackSharing(fallbackElement) {
    fallbackElement.classList.remove("hidden");
  }
};

export default WebShareApi;
```

### Bonus: Setup Copy to Clipboard as Fallback

We can improve the fallback sharing mechanism by adding a "Copy to Clipboard" button that copies the link to the clipboard if the Web Share API is not supported.

Since the fallback sharing mechanism also uses a button, we can use the same button for both the Web Share API and the Copy to Clipboard functionality. Let's adjust our markup accordingly.

```elixir
<div id="share-article" phx-hook="WebShareApi" data-title={@title} data-url={@link}>
  <button data-share-btn>Share</button>
</div>
```

We add the `data-share-btn` attribute to the button. We will use this attribute to identify the button in the JavaScript code.

Next, we need to adjust the JavaScript code to handle the copy to clipboard functionality and to only look for the `data-share-btn` attribute:

```javascript
const WebShareApi = {
  mounted() {
    const { title, url } = this.el.dataset;
    const shareData = { title, url };

    this.initializeSharing(shareData);
  },
  initializeSharing(shareData) {
    const shareButton = this.el.querySelector("button[data-share-btn]");

    if (!navigator.share && navigator.canShare(shareData) && shareButton) {
      this.setupWebSharing(shareButton, shareData);
    } else if (shareButton) {
      this.setupFallbackSharing(shareButton, shareData);
    } else {
      console.error("Can not initialize sharing");
    }
  },
  setupWebSharing(shareButton, shareData) {
    shareButton.addEventListener("click", async () => {
      try {
        await navigator.share(shareData);
      } catch (err) {
        console.error("Error sharing:", err);
      }
    });
  },
  setupFallbackSharing(shareButton, shareData) {
    shareButton.addEventListener("click", () => {
      navigator.clipboard.writeText(shareData.url);

      const originalText = shareButton.textContent;
      shareButton.textContent = "Link Copied";

      setTimeout(() => {
        shareButton.textContent = originalText;
      }, 2000);
    });
  }
};

export default WebShareApi;
```

We add an event listener to the button to handle the click event. When the button is clicked, the link is copied to the clipboard and the button text changes to "Link Copied". After a short delay, the button text changes back to the original text. We have not touched the Web Share API in this section. We just added a better fallback mechanism that is triggered when the Web Share API is not supported.

You can now test the application and see the new "Copy to Clipboard" button in action when the Web Share API is not supported.

## Conclusion

In this article, we have implemented the Web Share API in our Phoenix LiveView application. We created a custom hook that checks for Web Share API support and sets up the sharing functionality accordingly. We added a fallback mechanism that is triggered if the Web Share API is not supported. We also added a "Copy to Clipboard" button that will be displayed if the Web Share API is not supported.

Now it's time to add the Web Share API to your project and start sharing content with your users more easily.
