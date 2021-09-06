defmodule ExHelpers.MixProject do
  use Mix.Project

  @version "0.4.0"

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
      {:ecto_sql, "~> 3.6"},
      {:gettext, "~> 0.18"},
      {:jason, "~> 1.2"},
      {:floki, ">= 0.27.0"}
    ]
  end
end
