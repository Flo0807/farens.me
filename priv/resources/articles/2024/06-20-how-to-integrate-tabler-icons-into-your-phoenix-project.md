%{
  slug: "how-to-integrate-tabler-icons-into-your-phoenix-project",
  title: "How to integrate Tabler Icons into your Phoenix project",
  description: "Tabler Icons is one of the most popular icon library. This article shows how to integrate the icon library into Phoenix projects. We track the Tabler Icons source repository using Mix and use the Tailwind CSS plugin feature to build an icon component.",
  published: true,
  tags: ["Phoenix", "Tabler Icons", "Tailwind CSS"]
}
---

[Tabler Icons](https://tablericons.com/) is one of the most popular icon libraries. This article shows how to integrate the icon library into Phoenix projects. We will track the Tabler Icons source repository using Mix and use the Tailwind CSS plugin feature to create an icon component.

## Introduction

In almost every web application you will need icons to represent different actions or states. There are many icon libraries available, but one of the most popular is Tabler Icons. Tabler Icons is a set of over 5000 free, MIT-licensed, high quality SVG icons. The icons are maintained by [Paweł Kuna](https://twitter.com/codecalm) and come in two versions: filled and outlined.

This article shows how to integrate Tabler Icons into an existing Phoenix project.

## Tracking the Tabler Icons source repository

The first step is to track the Tabler Icons source repository using Mix. This will allow us to easily update the icons in our project when new icons are added or existing icons are updated.

To track the Tabler Icons source repository, we need to add the following to the `deps` function in the `mix.exs` file:

```elixir
{:tabler_icons, github: "tabler/tabler-icons", sparse: "icons", app: false, compile: false}
```

This will add the Tabler Icons repository as a dependency to our project. The `sparse` option is used to only download the `icons` directory from the repository. We set `app` to `false` because we don't want to read the app file. We also set `compile` to `false` because we don't want to compile the icons. We just want to download the icons so we can use them later in our Tailwind CSS config.

If you have not seen the above options before, you can find a detailed explanation of them in the [Mix documentation](https://hexdocs.pm/mix/1.17.1/Mix.Tasks.Deps.html).

After adding the dependency, we need to run `mix deps.get` to download the icons from the Tabler Icons repository. The icons will be downloaded to the `deps/tabler_icons/icons` directory.

## Updating the Tailwind CSS config

Next, we need to update the`tailwind.config.js`. We create a custom plugin that generates the CSS classes for the icons.

### Reading the SVG files

The first step is to make the plugin read the SVG files from the `deps/tabler_icons/icons` directory.

```javascript
module.exports = {
  // ...
  plugins: [
    plugin(function () {
      const iconsDir = path.join(__dirname, "../deps/tabler_icons/icons")
      const values = {}
      const icons = [
        ["", "/outline"],
        ["-filled", "/filled"],
      ]
      icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(iconsDir, dir)).forEach(file => {
          const name = path.basename(file, ".svg") + suffix
          values[name] = { name, fullPath: path.join(iconsDir, dir, file) }
        })
      })
    })
  ]
}
```

The above code reads the SVG files from the `deps/tabler_icons/icons` directory and creates an object with the icon names and their full paths. This way, we can easily reference the icons later.

The `values` object will look like this:

```javascript
{
  "user": { name: "user", fullPath: "/path/to/deps/tabler_icons/icons/outline/user.svg" },
  "user-filled": { name: "user-filled", fullPath: "/path/to/deps/tabler_icons/icons/filled/book.svg" },
  // ...
}
```

We append the suffix `-filled` to filled icon names to distinguish between the filled and outlined versions of the icons. Since outline should be the default, we don't append any suffix to the outline icons.

### Generating the CSS classes

Next, we need to get the plugin to generate the CSS classes for the icons. We want to add the CSS for elements that contain a `hero-*` class. For example, if we have an element with a `hero-user` class, we want to add the CSS for the user icon. To do this, we use the `matchComponent` function provided by Tailwind CSS.

```javascript
module.exports = {
  // ...
  plugins: [
    plugin(function ({ matchComponents, theme }) {
      const values = {}
      // read icons and add to values object

      matchComponents({
        "tabler": ({ name, fullPath }) => {
          const content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, "")

          return {
            [`--tabler-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
            "-webkit-mask": `var(--tabler-${name})`,
            "mask": `var(--tabler-${name})`,
            "mask-repeat": "no-repeat",
            "background-color": "currentColor",
            "vertical-align": "middle",
            "display": "inline-block",
            "width": theme("spacing.5"),
            "height": theme("spacing.5")
          }
        }
      }, { values })
    })
  ]
}
```

This code matches items with the `tabler-*`. It extracts the name and full path of the icon from the `values` object created earlier. It then reads the contents of the SVG file and generates the CSS classes for the icon. The CSS classes set the icon as the element's background image and set the width and height of the element to `theme("spacing.5")`. This way, we can easily control the size of the icons using Tailwind's CSS spacing utilities.

## Remove width and height from the SVG

The icons provided by the Tabler Icons library have width and height attributes set in the SVG files. We need to remove these attributes so that we can control the size of the icons using Tailwind CSS. 

We already have a regex that removes all line breaks and carriage returns from the path string. We can extend this to also remove the width and height attributes from the SVG files.

```javascript
const content = fs.readFileSync(fullPath).toString()
  .replace(/\r?\n|\r/g, "")
  .replace(/width="[^"]*"/, "")
  .replace(/height="[^"]*"/, "");
```

The final plugin code will look like this:

```javascript
module.exports = {
  // ...
  plugins: [
    plugin(function ({ matchComponents, theme }) {
      const iconsDir = path.join(__dirname, "../deps/tabler_icons/icons")
      const values = {}
      const icons = [
        ["", "/outline"],
        ["-filled", "/filled"],
      ]
      icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(iconsDir, dir)).forEach(file => {
          const name = path.basename(file, ".svg") + suffix
          values[name] = { name, fullPath: path.join(iconsDir, dir, file) }
        })
      })
      matchComponents({
        "tabler": ({ name, fullPath }) => {
          const content = fs.readFileSync(fullPath).toString()
            .replace(/\r?\n|\r/g, "")
            .replace(/width="[^"]*"/, "")
            .replace(/height="[^"]*"/, "");

          return {
            [`--tabler-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
            "-webkit-mask": `var(--tabler-${name})`,
            "mask": `var(--tabler-${name})`,
            "mask-repeat": "no-repeat",
            "background-color": "currentColor",
            "vertical-align": "middle",
            "display": "inline-block",
            "width": theme("spacing.5"),
            "height": theme("spacing.5")
          }
        }
      }, { values })
    })
  ]
}
```

## Build an icon component

Now that we have the CSS classes for the icons ready, we can create an icon component that makes it easy to use the icons in our Phoenix project.

```elixir
defmodule MyAppWeb.CoreComponents do
  use Phoenix.Component

  attr :name, :string, required: true
  attr :class, :string, default: nil

  def icon(%{name: "tabler-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end
end
```

This component takes the name of the icon as an argument and renders a `span` element with the icon name as a class. We also allow the user to pass additional classes. 

We can use this component in our templates like this:

```elixir
<.icon name="hero-user" class="bg-blue-600" />
```

Tailwind CSS will generate the appropriate CSS classes for the icon based on the plugin we built in the previous step, and the icon will be displayed with a blue background.

## Conclusion

In this article, we have shown how to integrate Tabler Icons into a Phoenix project. We tracked the Tabler Icons source repository using Mix, built an icon component that makes it easy to use the icons in markup, and used the Tailwind CSS plugin feature to add the appropriate CSS.

## Credits

I would like to credit the Phoenix team for the inspiration for this article. They are already using the same approach to integrate [Heroicons](https://heroicons.com/) into Phoenix projects. I just adapted it to work with Tabler Icons. For more information, you can check out [the Phoenix Asset Management guide](https://hexdocs.pm/phoenix/asset_management.html).
