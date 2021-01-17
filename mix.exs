defmodule AntlUtilsEcto.MixProject do
  use Mix.Project

  @source_url "https://github.com/annatel/antl_utils_ecto"
  @version "1.2.0"

  def project do
    [
      app: :antl_utils_ecto,
      version: @version,
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      docs: docs()
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
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:ecto, "~> 3.0"},
      {:antl_utils_elixir, "~> 0.2.0"}
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
