%{
  slug: "building-a-table-of-contents-component-for-a-phoenix-blog",
  title: "Building a Table of Contents Component for a Phoenix Blog",
  description: "This article shows how to parse MDEx generated HTML into a nested data strcuture that is used to build a table of contents component for a Phoenix blog.",
  published: true,
  tags: ["Floki", "MDEx", "Phoenix"]
}
---

This article shows how to parse [MDEx](https://github.com/leandrocp/mdex)-generated HTML into a nested data structure that is used to build a table of contents component for a Phoenix blog.

## Introduction

In this article, we are going to build a table of contents component that can be used in blogs or other markdown based pages. The table of contents component will display a link to each section of your content that allow users to quickly navigate through the content.

We assume that you have set up a Phoenix project and are using the MDEx markdown parser to render markdown content. We will configure MDEx to include IDs and anchor links for headings in the generated HTML that we can use to build the table of contents component. If you are not using MDEx, you can still follow along, but you will need to make some adjustments to the code to make it work with your markdown parser.

## Steps

### Configure MDEx

The first step is to configure the MDEx markdown parser to include IDs and anchor links for headings in the generated HTML. By default, MDEx does not include any IDs and or additional anchor links. To enable this feature, we need to set the `header_ids` option in the `extensions` keyword list when calling the `MDEx.to_html` function. This tells the MDEx markdown parser to include IDs and anchor links for headings in the generated HTML.

```elixir
MDEx.to_html(body, extension: [header_ids: ""])
```

In the code snippet above, we pass an empty string to the `header_ids` option. The string will be used as a prefix for the generated IDs. We do not necessarily need a prefix, but it can be useful to avoid conflicts with other IDs on the page.

You can see a list of all available extension in the [comrak documentation](https://docs.rs/comrak/latest/comrak/struct.ExtensionOptions.html) as MDEx uses Rust's comrak crate under the hood.

We can write a simple test to verify that the generated HTML includes the IDs and anchor links for headings:

```elixir
use ExUnit.Case

test "MDEx includes IDs and anchor links" do
  assert MDEx.to_html("## Introduction\n", extension: [header_ids: ""]) ==
            "<h2><a href=\"#introduction\" aria-hidden=\"true\" class=\"anchor\" id=\"introduction\"></a>Introduction</h2>\n"
end
```

As you can see, the generated HTML includes an anchor link with the ID `introduction` for the heading `## Introduction`.

### Parse and convert headings

The next step is to parse the generated HTML, extract the headings from it and transform them into a suitable data structure that we can use to build the table of contents component. We will use the [Floki](https://github.com/philss/floki) library for this. From the README: "Floki is a simple HTML parser that enables search for nodes using CSS selectors."

We will write a function that takes the generated HTML content as input, parses the headings, and returns a list of headings with labels, hrefs and subheadings.

```elixir
defp parse_headings(content) do
  content
  |> Floki.parse_fragment!()
  |> Enum.reduce([], fn
    {"h2", _class, child} = el, acc ->
      acc ++ [%{label: Floki.text(el), href: get_href(child), childs: []}]

    {"h3", _class, child} = el, acc ->
      List.update_at(acc, -1, fn %{childs: subs} = h2 ->
        %{h2 | childs: subs ++ [%{label: Floki.text(el), href: get_href(child), childs: []}]}
      end)

    _other, acc ->
      acc
  end)
end

def get_href(heading_element) do
  attr = heading_element |> Floki.find("a") |> Floki.attribute("href")

  case attr do
    [] -> nil
    [href | _] -> href
  end
end
```

The `parse_headings/1` function takes the generated HTML content as input. Since we are dealing with a string we first use the `Floki.parse_fragment!` function to parse the string into a Floki `html_tree()` data structure. We then use `Enum.reduce/3` to iterate over the html tree. We check if the element is an `h2` or `h3` element and extract the label and href. The label is the text content of the heading element and the href is generated using the `get_href/1` helper function (the `get_href/1` function searches for the anchor link in the heading element and returns the corresponding href attribute). If the element is an `h3` element, we need to add it as a child of the last `h2` element. This results in a nested data structure.

We can validate the function by writing a test that also demonstrates the resulting data structure:

```elixir
use ExUnit.Case

test "parse_headings" do
  headings =
    """
    ## Section 1

    ### Subsection 1.1

    ### Subsection 1.2

    ## Section 2
    """
    |> MDEx.to_html(extension: [header_ids: ""])
    |> parse_headings()

  expected = [
    %{
      label: "Section 1",
      childs: [
        %{label: "Subsection 1.1", childs: [], href: "#subsection-11"},
        %{label: "Subsection 1.2", childs: [], href: "#subsection-12"}
      ],
      href: "#section-1"
    },
    %{label: "Section 2", childs: [], href: "#section-2"}
  ]

  assert headings = expected
end
```

As you can see, the `parse_headings/1` function returns a list of headings with labels, hrefs and subheadings. This data structure is suitable for building the table of contents component because it represents the hierarchy of the headings in the content.

Note that we only parse `h2` and `h3` elements in this example. You can extend the function to include deeper heading levels if needed.

### Build the table of contents component

The last step is to build the actual table of contents component. It takes the list of parsed headings from the previous steps and an optional list of classes. Since we are using [daisyUI](https://daisyui.com/) in our Phoenix project, we can use the `menu` class to make the table of contents look like a sidebar menu by default (see [daisyUI menu component](https://daisyui.com/components/menu/)). We also add some other default classes. You can customize the component to fit your design.

The `toc/1` component renders an unordered list with list items and a link for each heading. If the current heading has child headings, the `toc` component is called recursively with them as input. This creates a nested HTML list structure that represents the headings data structure in the UI.

```elixir
@doc """
Renders a table of contents from a list of headings.
"""
attr :headings, :list, required: true
attr :class, :string, default: "menu w-56 p-0 opacity-60"

def toc(assigns) do
  ~H"""
  <ul class={@class}>
    <li :for={%{label: label, href: href, childs: childs} <- @headings}>
      <.link href={href}>
        <%= label %>
      </.link>
      <.toc :if={childs != []} headings={childs} class={nil} />
    </li>
  </ul>
  """
end
```

### Place the component in your layout

We are now ready to use the component in our layout. On my blog, I only show the table of contents on larger screens so I can place it next to the main content. I also made it sticky so that it stays visible while scrolling. Here is an example of how I placed the component in my layout:

```html
<div class="relative">
  <div class="absolute top-16 bottom-16 -left-14 w-10 text-xs">
    <div class="sticky top-6 hidden xl:block">
      <.toc headings={@article.heading_links} />
    </div>
  </div>
  <!-- Blog page content -->
</div>
```

The above code uses `absolute` positioning to place the table of contents on the left side of the main content. It is only visible on larger screens (`xl:block`) and is sticky so that it stays visible while scrolling. To not stick to the top of the page, we use the `top-6` class to save some space.

## Conclusion

In this article, we configured the Elixir MDEx markdown parser to include IDs and anchor links for headings in the generated HTML. We then parsed the generated HTML into a nested data structure we can pass to a table of contents component we built. This component renders a list of links to the headings in the content, creating a table of contents that allows users to quickly navigate through the content.
