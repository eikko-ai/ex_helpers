defmodule ExHelpers.MixProject do
  use Mix.Project

  @version "0.9.2"

  def project do
    [
      app: :ex_helpers,
      version: @version,
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.8"},
      {:gettext, "~> 0.19"},
      {:jason, "~> 1.3"},
      {:floki, ">= 0.32.1"}
    ]
  end
end
