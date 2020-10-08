defmodule AntlUtilsEcto.MixProject do
  use Mix.Project

  def project do
    [
      app: :antl_utils_ecto,
      version: "0.3.0",
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
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
      {:antl_utils_elixir, "~> 0.1"}
    ]
  end

  defp description() do
    "Elixir Ecto utils."
  end

  defp package() do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/annatel/antl_utils_ecto"}
    ]
  end
end
