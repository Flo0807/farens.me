defmodule Website.MixProject do
  use Mix.Project

  def project do
    [
      app: :website,
      version: "0.0.0",
      elixir: "~> 1.16",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix_live_view] ++ Mix.compilers(),
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
      {:phoenix, "== 1.7.21"},
      {:phoenix_html, "== 4.2.1"},
      {:phoenix_live_view, "== 1.1.2"},
      {:bandit, "== 1.7.0"},

      # SEO & Content
      {:phoenix_seo, "== 0.1.11"},
      {:atomex, "== 0.5.1"},
      {:mdex, "== 0.8.1"},
      {:yaml_elixir, "== 2.11.0"},
      {:nimble_publisher, "== 1.1.1"},

      # Monitoring and Telemetry
      {:phoenix_live_dashboard, "== 0.8.7"},
      {:telemetry_metrics, "== 1.1.0"},
      {:telemetry_poller, "== 1.3.0"},

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
      {:floki, "== 0.38.0"},

      # Dev and Test
      {:phoenix_test, "== 0.7.0", only: :test, runtime: false},
      {:phoenix_test_playwright, "== 0.7.1", only: :test, runtime: false},
      {:a11y_audit, "== 0.2.3", only: :test},
      {:esbuild, "== 0.10.0", runtime: Mix.env() == :dev},
      {:tailwind, "== 0.3.1", runtime: Mix.env() == :dev},
      {:phoenix_live_reload, "== 1.6.0", only: :dev},
      {:tailwind_formatter, "== 0.4.2", only: [:dev, :test], runtime: false},
      {:credo, "== 1.7.12", only: [:dev, :test], runtime: false},
      {:lazy_html, "== 0.1.3", only: :test}
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
