defmodule Website.MixProject do
  use Mix.Project

  def project do
    [
      app: :website,
      version: "0.0.0",
      elixir: "~> 1.16",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Website.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # Core
      {:phoenix, "== 1.7.20"},
      {:phoenix_html, "== 4.2.1"},
      {:phoenix_live_view, "== 1.0.5"},
      {:bandit, "== 1.6.7"},

      # SEO & Content
      {:phoenix_seo, "== 0.1.11"},
      {:atomex, "== 0.5.1"},
      {:mdex, "== 0.3.3"},
      {:yaml_elixir, "== 2.11.0"},
      {:nimble_publisher, "== 1.1.1"},

      # Monitoring and Telemetry
      {:phoenix_live_dashboard, "== 0.8.6"},
      {:telemetry_metrics, "== 1.1.0"},
      {:telemetry_poller, "== 1.1.0"},

      # UI
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.2.0",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},

      # Utilities
      {:gettext, "== 0.26.2"},
      {:jason, "== 1.4.4"},
      {:dns_cluster, "== 0.2.0"},
      {:floki, "== 0.37.0"},

      # Dev and Test
      {:esbuild, "== 0.9.0", runtime: Mix.env() == :dev},
      {:tailwind, "== 0.2.4", runtime: Mix.env() == :dev},
      {:phoenix_live_reload, "== 1.5.3", only: :dev},
      {:tailwind_formatter, "== 0.4.2", only: [:dev, :test], runtime: false},
      {:credo, "== 1.7.11", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "assets.setup", "assets.build"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": [
        "tailwind default --minify",
        "esbuild default --minify --loader:.ttf=file",
        "phx.digest"
      ]
    ]
  end
end
