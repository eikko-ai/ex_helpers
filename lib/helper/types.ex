defmodule Helper.Types do
  @moduledoc false

  @doc """
  ## Examples:

    iex>Types.typeof("Hello World")
    "binary"

    iex>Types.typeof(1)
    "integer"

    iex>Types.typeof(self())
    "pid"

    iex>Types.typeof('this is char list')
    "list"

  """
  def typeof(term) when is_atom(term), do: "atom"
  def typeof(term) when is_boolean(term), do: "boolean"
  def typeof(term) when is_function(term), do: "function"
  def typeof(term) when is_list(term), do: "list"
  def typeof(term) when is_map(term), do: "map"
  def typeof(term) when is_nil(term), do: "nil"
  def typeof(term) when is_pid(term), do: "pid"
  def typeof(term) when is_port(term), do: "port"
  def typeof(term) when is_reference(term), do: "reference"
  def typeof(term) when is_tuple(term), do: "tuple"

  def typeof(term) when is_binary(term), do: "binary"
  def typeof(term) when is_bitstring(term), do: "bitstring"

  def typeof(term) when is_integer(term), do: "integer"
  def typeof(term) when is_float(term), do: "float"
  def typeof(term) when is_number(term), do: "number"

  def typeof(_), do: :error

  # credo:disable-for-next-line
  def type_of(term) do
    cond do
      is_atom(term) -> "atom"
      is_boolean(term) -> "boolean"
      is_function(term) -> "function"
      is_list(term) -> "list"
      is_map(term) -> "map"
      is_nil(term) -> "nil"
      is_pid(term) -> "pid"
      is_port(term) -> "port"
      is_reference(term) -> "reference"
      is_tuple(term) -> "tuple"
      is_binary(term) -> "binary"
      is_bitstring(term) -> "bitstring"
      is_integer(term) -> "integer"
      is_float(term) -> "float"
      is_number(term) -> "number"
      true -> :error
    end
  end

  @equal_types %{
    "number" => ["integer", "float"],
    "string" => ["binary", "bitstring"]
  }

  @doc """
  ## Examples:

    iex> Specs.type_compare(1.3, "number" )
    true
    iex> Specs.type_compare(1.3, "integer")
    false
    iex> Specs.type_compare(1.3, "float")
    true
  """
  @spec type_compare(any, binary) :: boolean
  def type_compare(term, type) when is_binary(type) do
    term_type = typeof(term)
    term_type == type or term_type in (@equal_types[type] || [])
  end

  def integerfy(id) when is_binary(id), do: String.to_integer(id)
  def integerfy(id), do: id

  def stringfy(v) when is_binary(v), do: v
  def stringfy(v) when is_integer(v), do: to_string(v)
  def stringfy(v) when is_atom(v), do: to_string(v)
  def stringfy(v), do: v

  def is_datetime?(%DateTime{}), do: true
  def is_datetime?(_), do: false
end
