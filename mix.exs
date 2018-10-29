defmodule Pilot.Mixfile do
  use Mix.Project

  @version File.read!("VERSION") |> String.strip

  def project do
    [
      app:              :pilot,
      name:             "Pilot",
      version:          @version,
      elixir:           "~> 1.5",
      build_embedded:   Mix.env == :prod,
      start_permanent:  Mix.env == :prod,
      deps:             deps(),
      description:      description(),
      package:          package(),
      docs: [
        readme:     "README.md",
        main:       "README",
        source_ref: "v#{@version}",
        source_url: "https://github.com/metismachine/pilot",
      ]
    ]
  end

  def application do
    [
      extra_applications: [
        :logger,
        :cowboy,
        :plug,
      ],
    ]
  end

  defp deps do
    [
      {:cowboy, "~> 2.5"},
      {:plug_cowboy, "~> 2.0"},
      {:plug,   "~> 1.4"},
      {:poison, "~> 3.1"}
    ]
  end

  defp description do
    """
    DSL for creating REST API applications with minimal effort
    """
  end

  defp package do
    [
      maintainers:  ["Wess Cope"],
      licenses:     ["MIT"],
      links:        %{"Github" => "https://github.com/metismachine/pilot"},
      files:        ~w(mix.exs README.md LICENSE lib VERSION),
    ]
  end
end
