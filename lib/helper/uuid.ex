defmodule Helper.UUID do
  @moduledoc false

  def generate do
    Ecto.UUID.generate()
  end

  def generate(:hex) do
    generate()
    |> String.replace("-", "")
    |> String.upcase()
  end

  def regex do
    ~r/^[0-9a-f]{8}\-[0-9a-f]{4}\-[0-9a-f]{4}\-[0-9a-f]{4}\-[0-9a-f]{12}$/
  end

  def hex_regex do
    ~r/^[0-9a-fA-F]{32}$/
  end
end
