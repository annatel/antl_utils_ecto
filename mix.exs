defmodule AntlUtilsEcto.MixProject do
  use Mix.Project

  @source_url "https://github.com/annatel/antl_utils_ecto"
  @version "2.10.1"

  def project do
    [
      app: :antl_utils_ecto,
      version: @version,
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      docs: docs(),
      xref: [exclude: [Shortcode]]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:antl_utils_elixir, "~> 1.4"},
      {:ecto, ">= 3.8.4"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:jason, "~> 1.2"},
      {:shortcode, "~> 0.7"}
    ]
  end

  defp description() do
    "Elixir Ecto utils."
  end

  defp package() do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: @source_url,
      extras: [
        "README.md"
      ]
    ]
  end
end
