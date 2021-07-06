defmodule Helper.Math do
  @moduledoc """
  Math helper functions.
  """

  @doc """
  Convert an angle in degrees to radians

      Example:
      iex> to_radian(90)
      iex> 1.5707963267948966
  """
  def to_radian(degree),
    do: degree * (:math.pi() / 180)
end
