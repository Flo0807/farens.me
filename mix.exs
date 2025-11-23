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
      deps: deps(),
      compilers: [:phoenix_live_view] ++ Mix.compilers(),
      listeners: [Phoenix.CodeReloader]
    ]
  end

  def cli do
    [
      preferred_envs: [precommit: :test]
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
      {:phoenix, "1.8.1"},
      {:phoenix_html, "4.3.0"},
      {:phoenix_live_view, "1.1.17"},
      {:bandit, "1.8.0"},

      # SEO & Content
      {:phoenix_seo, "0.1.11"},
      {:atomex, "0.5.1"},
      {:mdex, "0.10.0"},
      {:yaml_elixir, "2.12.0"},
      {:nimble_publisher, "1.1.1"},

      # Monitoring and Telemetry
      {:phoenix_live_dashboard, "0.8.7"},
      {:telemetry_metrics, "1.1.0"},
      {:telemetry_poller, "1.3.0"},

      # UI
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.2.0",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},

      # Utilities
      {:gettext, "1.0.2"},
      {:jason, "1.4.4"},
      {:dns_cluster, "0.2.0"},
      {:floki, "0.38.0"},

      # Dev and Test
      {:phoenix_test, "0.9.1", only: :test, runtime: false},
      {:phoenix_test_playwright, "0.9.1", only: :test, runtime: false},
      {:a11y_audit, "0.3.0", only: :test},
      {:esbuild, "0.10.0", runtime: Mix.env() == :dev},
      {:tailwind, "0.4.1", runtime: Mix.env() == :dev},
      {:phoenix_live_reload, "1.6.1", only: :dev},
      {:tailwind_formatter, "0.4.2", only: [:dev, :test], runtime: false},
      {:credo, "1.7.13", only: [:dev, :test], runtime: false},
      {:lazy_html, "0.1.8", only: :test},
      {:tidewave, "== 0.5.2", only: :dev},
      {:igniter, "0.7.0", only: [:dev, :test]},
      {:usage_rules, "0.1.26", only: [:dev]}
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
      ],
      precommit: ["compile --warning-as-errors", "deps.unlock --unused", "format", "test"]
    ]
  end
end
