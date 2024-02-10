%{
  slug: "hello-world",
  title: "Hello World! Introduction to my website and blog",
  description: "This is about why Elixir and Phoenix were chosen over a static site generator to build this website, along with explanations and code examples of how some interesting features work in detail.",
  published: true
}
---
I talk about why Elixir and Phoenix were chosen over a static site generator to build this website, along with explanations and code examples of how some interesting features work in detail.

## Introduction

I've just published the redesign and refactoring of my blog, so it's time for a *Hello World* article where I talk about some exciting features of this site. 

First of all, welcome to my blog! I am glad that you are here and appreciate your time to read this.

I am always open to feedback and suggestions. If you find something broken on this site, have an idea for a blog post, find a mistake in a post, or just want to chat, drop me a line!

## Why Elixir and Phoenix?

The website is powered by [Elixir](https://elixir-lang.org/) and [Phoenix](https://www.phoenixframework.org/). Elixir is a powerful dynamic, functional programming language and Phoenix is the web framework of choice for it. With Phoenix and the Elixir ecosystem, you can build complex web applications. In addition to that, with [Phoenix LiveView](https://hexdocs.pm/phoenix_live_view/welcome.html), you can make your web application even more powerful by adding real-time capabilities with server-rendered HTML.

Sounds a bit overkill for a simple blog, doesn't it? So why are these technologies powering my website and blog instead of a static site generator?

Because Elixir and Phoenix make building web applications so much fun. Over the past two years, Elixir has become one of my favorite programming languages. So of course I used these technologies to build my website. In my opinion, Phoenix and Elixir are good choices even for such small projects. I am always open to new frameworks and programming languages and have used many in past projects, but currently I really stick to Elixir and Phoenix. Also, it's cool to have a playground and project where I can try out new features and experiment with the framework and language.

If you are interested in the source code of this website and blog, it is available to the public on GitHub ([https://github.com/Flo0807/farens.me](https://github.com/Flo0807/farens.me)).

Let's dive in even deeper and discuss how certain features are built.


## The Blog

### Publishing Engine

When the website was first published, I wrote my own parser for markdown files and repository for blog posts, but for the redesign I looked into [NimblePublisher](https://github.com/dashbitco/nimble_publisher). A package that does the same, but more conveniently, by providing easy to use APIs.

To parse Markdown files, we only need two files.

**Schema module**

In the schema module we define a struct with all the keys our resource should have along with a `build/2` function that fills in the keys. The `build/2` function creates the resource struct based on the front matter (attributes) and content (parsed as HTML) of the markdown file.

NimblePublisher could just require a `body` key for the content of the markdown file and a key for each attribute to create the struct automatically, but typically, you do not want that. The `build/2` function is useful for calculating values and converting attributes. For example, for this blog article, we will determine the publication date based on the resource path and calculate a read time based on the content, as shown in the following example.

```elixir
defmodule Website.Blog.Article do
  defstruct id: "",
            slug: "",
            title: "",
            date: nil,
            description: "",
            body: "",
            read_minutes: 0,
            published: false

  def build(filename, attrs, body) do
    # extract and parse date from filename
    [year, month_day_id] = filename |> Path.rootname() |> Path.split() |> Enum.take(-2)
    [month, day, id] = String.split(month_day_id, "-", parts: 3)
    date = Date.from_iso8601!("#{year}-#{month}-#{day}")

    read_minutes = # calculate read minutes based on content

    struct!(
      __MODULE__,
      [id: id, date: date, body: body, read_minutes: read_minutes] ++ Map.to_list(attrs)
    )
  end
end
```

**Context module**

The second file you need to parse markdown files is a context module. The context module provides APIs for your application to fetch resources. The way it works is that it provides NimblePublisher with all the information it needs to parse a resource (e.g. the path and name of the resource). NimblePublisher then fetches the appropriate files, parses the header and content, and calls the `build/2` function of your resource. It then creates a module attribute containing a list of resources you can use to build your own API based on your needs. For example I first sort the articles by date and then provide a function to fetch all articles or the most recent ones.

```elixir
defmodule Website.Blog do
  use NimblePublisher,
    build: Website.Blog.Article,
    from: Application.app_dir(:website, "priv/resources/articles/**/*.md"),
    as: :articles

  @articles Enum.sort_by(@articles, & &1.date, {:desc, Date})

  def all_articles, do: @articles

  def recent_articles(count \\ 3), do: Enum.take(all_articles(), count)
end
```

That's it! You can now insert the parsed HTML from markdown files into specific pages by calling `article.body`.

Side note: I maintain my projects the same way!

### Syntax Highlighting

After I created the context and schema module and displayed the HTML on my blog page for the first time, I was a bit disappointed. The syntax highlighting of the code snippets did not work out of the box. When I looked into the documentation of the NimblePublisher package, I saw that you need to install additional packages that provide syntax highlighting. Also, you have to generate CSS for the *highlighting theme* you want to use and add it to your application.

This did not convince me, and I could not believe that making syntax highlighting work was that complicated. And yes, I came up with a much simpler solution.

I wanted to try out a new hex.pm package called [MDEx](https://github.com/leandrocp/mdex) that was recently released anyway. It's another Markdown parser and an alternative to [Earmark](https://github.com/pragdave/earmark) (Earmark used by default by NimblePublisher) that promises to be really fast. I was about to read the documentation on how to set up a custom Markdown converter to use MDEx when I stumbled across MDEx's feature list, which includes syntax highlighting. So it promises to make our parsing much faster and the syntax highlighting just works out of the box, isn't that cool?

Let's get MDEx to work with NimblePublisher.

When using NimblePublisher in your context module, you can set the `html_converter` option to specify a custom converter module to convert Markdown to HTML. This module must include a `convert/4` function. The `convert/4` function receives the extension, body and attributes of the markdown file as well as any options.

The function is expected to return the converted body as an (HTML) string. With this setup, we can now hook into the conversion of the markdown body and use MDEx instead of Earmark, which also gives us syntax highlighting. All we need to do is call the MDEx `to_html/1` function along with the corresponding body. There is also a `to_html/2` function that we can use to pass additional options. For example, we could change the theme of code blocks by setting the `syntax_highlight_theme` option.

```elixir
defmodule Website.MarkdownConverter do
  def convert(_extension, body, _attrs, _opts) do
    MDEx.to_html(body)
  end
end
```

```elixir
defmodule Website.Blog do
  use NimblePublisher,
    html_converter: Website.MarkdownConverter,
    # other options
end
```

We are done! The markdown is properly parsed into HTML and code blocks are styled and highlighted. Unlike with the "standard" NimblePublisher way of syntax highlighting (which uses [Makeup](https://hexdocs.pm/makeup/1.1.0/Makeup.html) under the hood), we do not need to include any CSS or install any packages to our application when using MDEx Markdown conversion.

The MDEx syntax highlighting is powered by Autumn. You can find a list of available themes in [the Autumn GitHub repository](https://github.com/leandrocp/autumn).

### Live Reloading

A nice quality of life addition would be live reloading. In terms of live reloading, I refer to reload the page automatically when the content of a markdown file changes. This way, you can see your blog posts being updated in real-time during development.

Phoenix provides the [Phoenix.LiveRouter](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.Router.html) that can be used for live-reload detection in development. Its already set up in new Phoenix projects and reloads the application when code changes. We just need to include another regex pattern to our dev config that targets our resource markdown files.

```elixir
config :website, WebsiteWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/resources/.*(md|markdown)$",
      # other patterns
    ]
  ]
```

Now the application reloads when the content of markdown files changes. NimblePublisher does not need to be configured at all and parses the new content when the application is refreshed.

### Live User Count

You may have noticed a little detail on this blog post page. Below the title, date and reading time, it shows the number of people reading this post right now (yes, this is live, try it by opening this page in another browser tab). Actually, one of the reasons I built it was to justify using Phoenix for this project (I am sure I had many problems building this feature with a static generator).

I will leave you with a teaser and cover the implementation details in another post. What I can say now is that the user counter uses a built-in feature of Phoenix called [Phoenix.Presence](https://hexdocs.pm/phoenix/Phoenix.Presence.html), which makes it not complicated to add a real-time user counter to your blog posts.

## Design and Themes

The website uses [Tailwind CSS](https://tailwindcss.com/) and [daisyUI](https://daisyui.com/) for styling. Tailwind is a CSS framework that provides countless utilities that you can use directly in your markup to quickly create a great looking website. Tailwind is even included and configured in new Phoenix projects. While there is a never-ending discussion about whether or not it is a good idea to overuse inline styles, I have no problem with it.

In addition to Tailwind, I wanted to give daisyUI a try. I had used it in other projects and liked working with it. It's a framework built on top of Tailwind that provides UI components. These components are not real components, but rather Tailwind wrapper classes that you can use in your markup. For example, there is a `btn` class that you can add to your HTML button to style it. Since the framework only provides classes and only uses CSS and Tailwind, it can be used by almost any framework and is not tied to one.

Unlike pure Tailwind, you do not define hard-coded colors in your markup (e.g. `bg-slate-700`). With daisyUI you use variable colors like `bg-base-200`. This is useful if you want to implement multiple color themes because you only need to add one class to your markup that represents multiple colors based on the selected theme. In addition, daisyUI comes with many themes by default. 

In summary, daisyUI gave me a good starting point for my design and made it easy to customize.

Because of the daisyUI classes, adding a theme switch that supports multiple themes was not difficult. I just included some predefined daisyUI themes in my `tailwind.config.js` and set the `data-theme` attribute on my HTML root element accordingly.

```javascript
// tailwind.config.js
module.exports = {
  daisyui: {
    themes: ["night", "dark", "sunset", "dracula"],
  },
  // other options
}
```
```html
<html lang="en" data-theme="night"></html>
```

To add interactivity to the theme switch, I wrote a [Phoenix LiveView JavaScript Hook](https://hexdocs.pm/phoenix_live_view/js-interop.html#client-hooks-via-phx-hook) that changes the `data-theme` attribute when a new theme is selected and stores the corresponding value in local storage to load the selected theme on page reloads.

```javascript
const ThemeSwitch = {
  mounted() {
    this.el.addEventListener('change-theme', (event) => {
      const theme = event.detail.theme;
      document.documentElement.setAttribute('data-theme', theme);
      localStorage.setItem('theme', theme);
    });
  },
}

export default ThemeSwitch;
```

## Conclusion 

I recommend that every developer creates a little playground project to try out new features and experiment with new technologies. It can be a blog, a portfolio, or a small web application, and it does not have to be public. It's a great way to learn new things and keep up with the latest technologies. This website and blog is my playground and I am happy with the result. I look forward to writing more articles and adding new features.
