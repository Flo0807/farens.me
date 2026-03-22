defmodule WebsiteWeb.SEO do
  @moduledoc """
  SEO configuration for the website.
  """
  use WebsiteWeb, :verified_routes

  use SEO,
    site: &__MODULE__.site_config/1,
    open_graph: &__MODULE__.open_graph_config/1,
    twitter: &__MODULE__.twitter_config/1

  @default_description "Personal website and blog of Florian Arens. Software Engineer passionate about leveraging AI to accelerate software development."

  @doc """
  Configures the Twitter card.
  """
  def twitter_config(conn) do
    SEO.Twitter.build(
      site: "@flo_arens",
      creator: "@flo_arens",
      title: conn.assigns.page_title,
      card: :summary_large_image,
      image: "https://og-image.farens.me/image?text=#{conn.assigns[:og_image_text]}",
      description: conn.assigns[:meta_description] || @default_description
    )
  end

  @doc """
  Configures the Open Graph.
  """
  def open_graph_config(conn) do
    SEO.OpenGraph.build(
      title: conn.assigns.page_title,
      description: conn.assigns[:meta_description] || @default_description,
      locale: "en_US",
      image: "https://og-image.farens.me/image?text=#{conn.assigns[:og_image_text]}",
      url: conn.assigns.current_url
    )
  end

  @doc """
  Configures the site.
  """
  def site_config(conn) do
    SEO.Site.build(
      canonical_url: conn.assigns.current_url,
      description: conn.assigns[:meta_description] || @default_description
    )
  end
end
