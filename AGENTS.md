# AGENTS.md

## Project Overview

This is the personal website and blog of Florian Arens (https://farens.me), a software developer and computer science student. The website serves as a digital portfolio, knowledge-sharing platform, and technical playground for exploring Elixir and Phoenix LiveView capabilities.

**Purpose:**
Built with Phoenix LiveView instead of traditional static site generators to enable real-time functionality and interactive features that showcase modern web development practices.

**Key Pages:**
- Home (`/`)
- Blog index and individual articles (`/blog`, `/blog/:slug`)
- Projects portfolio (`/projects`)
- About page (`/about`)
- Privacy and legal pages

## Tech Stack

## Programming Language

- **Elixir**: Functional programming language for building scalable and maintainable applications

## Framework

- **Phoenix LiveView**: Real-time web framework for Elixir

## Styling

- **Tailwind CSS**: utility-first CSS framework
- **daisyUI**: Tailwind CSS plugin and component librarx

## Development Guidelines

### Usage Rules

Always consult the `usage_rules.md` file for the usage of packages in this project. It contains guidelines directly from package authors and additional development guidelines (e.g., for Elixir, Phoenix, and Phoenix LiveView). Review these guidelines early and often during development.

### Quality Assurance

1. **Run the precommit check**: Use `mix precommit` alias when you are done with all changes and fix any pending issues
  - This runs formatting, linting, tests, and other quality checks
  - Address all errors and warnings before considering work complete
2. **Manual testing**: Use Chrome DevTools MCP to test your changes at http://localhost:4000
  - Test in multiple browser viewports (mobile, tablet, desktop)
  - Verify all interactive elements work correctly
  - Check for console errors or warnings

### Finding Documentation

1. **Elixir ecosystem packages**: Use Tidewave MCP to find the documentation for Elixir packages (e.g., `phoenix` and `phoenix_live_view`)
2. **Frontend libraries and other packages**: Use Context7 MCP server for daisyUI, Tailwind CSS, and other non-Elixir packages

**Before implementing features:**
- Search the codebase for similar existing patterns
- Check if there are reusable components or functions
- Understand the architectural patterns used in the project

### Styling

**CSS Framework Stack:**
- **Primary**: daisyUI components (built on Tailwind CSS)
- **Secondary**: Tailwind CSS utility classes
- **Approach**: Mobile-first responsive design

**Best Practices:**

1. **Component hierarchy**:
  - Look for existing Phoenix Components in the codebase (e.g., in `lib/website_web/components/core_components.ex`)
  - Use daisyUI components when available (use Context7 to fetch documentation)
  - Build custom components with Tailwind CSS utilities and daisyUI component classes
  - Always prefer reusing existing components over creating new ones

2. **Styling daisyUI components**:
  - daisyUI components can be styled using Tailwind CSS classes
  - Add utility classes directly to daisyUI component markup: `<button class="btn btn-primary mt-4 shadow-lg">Submit</button>`

3. **Responsive design**:
  - Use mobile-first approach (base styles are for mobile, add `md:`, `lg:` prefixes for larger screens)
  - Test all breakpoints: mobile (default), tablet (`md:`), desktop (`lg:`, `xl:`)
  - Ensure touch targets are at least 44x44px on mobile

4. **Color and theming**:
  - Use daisyUI semantic color classes (`primary`, `secondary`, etc.)
  - Avoid hard-coded color values; use theme variables for consistency
  - Ensure color choices meet accessibility contrast requirements

5. **Component organization**:
  - Create reusable components in `lib/website_web/components/core_components.ex`
  - Keep components small and focused on a single responsibility

### Accessibility (A11Y)

Accessibility is **mandatory**, not optional. All features must be fully accessible.

1. **Semantic HTML**: Use proper HTML5 semantic elements (`<nav>`, `<main>`, `<article>`, `<section>`, etc.)
2. **ARIA attributes**: Add ARIA labels where text content is not sufficient (`aria-label`, `aria-labelledby`)
3. **Keyboard navigation**: All interactive elements must be keyboard accessible (focusable with Tab)
4. **Visual accessibility**: Use appropriate font sizes, ensure color contrast meets accessibility requirements, and add sufficient spacing and touch target sizes
5. **Screen reader compatibility**: Provide alt text for all images, use `sr-only` Tailwind class for screen-reader-only content when needed
6. **Forms accessibility**: Always use `<label>` elements associated with form inputs

### Code Organization

1. **Module structure**:
  - Keep LiveView modules focused
  - Separate HTML templates from LiveView logic (e.g., `index.ex` and `index.html.heex`)
  - Extract business logic into context modules (e.g., `Accounts`, `Products`)
  - Create separate modules for complex queries or operations
  - Use `lib/website/` for business logic, `lib/website_web/` for web interface

3. **Reusability**:
  - Create shared components in `lib/website_web/components/core_components.ex`
  - Extract common patterns into functions
  - Don't repeat yourself (DRY) but don't over-abstract too early
   
### SEO

This project uses the `phoenix_seo` package to manage SEO metadata, Open Graph tags, Twitter cards, and structured data.

**Central Configuration:**
The `lib/website_web/seo.ex` module contains the default SEO configuration for the entire site.

**Page-Specific SEO:**
For every LiveView page, you must set these two assigns in the `mount/3` function:
- `:page_title` - Used for the `<title>` tag and social media sharing
- `:og_image_text` - Text parameter for the dynamic Open Graph image generator

**Resource-Specific SEO:**
For resources like blog articles, implement the `phoenix_seo` protocols to provide custom SEO metadata. See `lib/website/blog/article_impl.ex` for a complete example. When creating new resource types (e.g., projects, case studies), follow the same pattern.

**General SEO Guidelines:**

1. **Page Titles**:
  - Keep titles under 60 characters to avoid truncation in search results
  - Make titles descriptive and unique for each page
  - Use title case for consistency

2. **Meta Descriptions**:
  - Keep descriptions between 150-160 characters
  - Write compelling, action-oriented copy that encourages clicks
  - Include relevant keywords naturally

3. **Structured Data**:
  - Use breadcrumbs for pages with hierarchical navigation
  - Include relevant metadata like publish dates, authors, and reading time

4. **URLs**:
  - Keep URLs short, descriptive, and keyword-rich
  - Use lowercase letters and hyphens (not underscores)

5. **Content**:
  - Use proper heading hierarchy (h1 → h2 → h3)
  - Include only one h1 per page
  - Ensure content is unique and valuable

### Content Management

1. Uses **NimblePublisher** for content management and static files
2. Store content in Markdown with front matter (see blog articles: `priv/resources/articles/`)

### Git Workflow

1. **Commit messages**:
  - Write clear, descriptive commit messages
  - Use present tense ("Add feature" not "Added feature")
  - Reference issue numbers when applicable

2. **Branch strategy**:
  - Create feature branches for new work
  - Keep commits focused and atomic
  - Rebase or merge from main regularly to stay up to date

3. **Before pushing**:
  - Run `mix precommit` to ensure all checks pass
  - Review your own changes (diff) before committing
  - Ensure tests pass locally
