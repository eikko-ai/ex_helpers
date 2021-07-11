defmodule Helper.Viz.Radar do
  require Integer

  alias Helper.Math

  def shape(values, scale \\ 1.0, rotation \\ 0, y_axis \\ "down") when is_list(values) do
    legs = find_legs(values, scale, rotation)
    vertices = find_vertices(legs, y_axis)

    # Returning Tuples of Tuples should be fine
    Enum.zip(legs, vertices)
    # But a Map is more descriptive
    |> Enum.map(fn {{length, angle}, {x, y}} ->
      %{
        leg: %{
          length: length,
          angle: angle
        },
        vertice: %{
          x: x,
          y: y
        }
      }
    end)
  end

  def find_legs(values, scale \\ 1.0, rotation \\ 0) when is_list(values) do
    lengths = find_lengths(values, scale)
    angles = find_angles(values, rotation)

    Enum.zip(lengths, angles)
  end

  def find_lengths(values, scale \\ 1.0) when is_list(values) do
    # are just scaled out versions of values
    Enum.map(values, &(&1 * scale))
  end

  def find_angles(legs, rotation \\ 0)

  def find_angles(legs, rotation) when is_list(legs) do
    find_angles(length(legs), rotation)
  end

  def find_angles(legs, rotation) when is_integer(legs) do
    # the angle between each leg
    angle = 360 / legs

    offset =
      if Integer.is_even(legs),
        # first and last vertices should be parallel
        do: -(angle / 2),
        # first vertice should be aligned to center
        else: -angle

    # apply some offset rotation, if desired
    offset = offset + rotation

    Enum.scan(1..legs, offset, fn _part, offset -> offset + angle end)
  end

  def find_vertices(legs, y_axis \\ "down") when is_list(legs) do
    Enum.map(legs, &find_vertice(&1, y_axis))
  end

  def find_vertice({length, angle}, y_axis \\ "down") do
    # some cartesian models are based on an inverted y axis
    case y_axis do
      "down" ->
        {
          find_x({length, angle}),
          -find_y({length, angle})
        }

      _ ->
        {
          find_x({length, angle}),
          find_y({length, angle})
        }
    end
  end

  def find_x({length, angle}) do
    # r x sin(O)
    Float.round(length * :math.sin(Math.to_radian(angle)), 1)
  end

  def find_y({length, angle}) do
    # r x cos(O)
    Float.round(length * :math.cos(Math.to_radian(angle)), 1)
  end
end
