defmodule Helper.Utils do
  @moduledoc false
  import Helper.ErrorHandler

  ## Config

  @doc """
  Get a config key from the application env
  """
  def get_config(section, key, app \\ Helper.otp_app())

  def get_config(section, :all, app) do
    app
    |> Application.get_env(section)
    |> case do
      nil -> ""
      config -> config
    end
  end

  def get_config(section, key, app) do
    app
    |> Application.get_env(section)
    |> case do
      nil -> ""
      config -> Keyword.get(config, key)
    end
  end

  ## General

  def is_datetime?(%DateTime{}), do: true
  def is_datetime?(_), do: false

  @doc """
  Handle General {:ok, ..} or {:error, ..} return
  """
  def done(nil, :boolean), do: {:ok, false}
  def done(_, :boolean), do: {:ok, true}
  def done(nil, err_msg), do: {:error, err_msg}
  def done({:ok, _}, with: result), do: {:ok, result}
  def done({:error, error}, with: _result), do: {:error, error}

  def done({:ok, %{id: id}}, :status), do: {:ok, %{done: true, id: id}}
  def done({:error, _}, :status), do: {:ok, %{done: false}}

  def done(nil, queryable, id), do: {:error, not_found_formater(queryable, id)}
  def done(result, _, _), do: {:ok, result}

  def done(nil), do: {:error, "record not found."}

  # For delete_all, update_all
  def done({n, nil}) when is_integer(n), do: {:ok, %{done: true}}

  def done(result), do: {:ok, result}

  ## Maps

  def map_key_atomify(%{__struct__: _} = map) when is_map(map) do
    map = Map.from_struct(map)
    map |> Enum.reduce(%{}, fn {key, val}, acc -> Map.put(acc, String.to_atom(key), val) end)
  end

  def map_key_atomify(map) when is_map(map) do
    Map.new(map, fn {key, val} -> {String.to_atom(key), val} end)
  end

  def map_key_stringify(%{__struct__: _} = map) when is_map(map) do
    map = Map.from_struct(map)
    map |> Enum.reduce(%{}, fn {key, val}, acc -> Map.put(acc, to_string(key), val) end)
  end

  def map_key_stringify(map) when is_map(map) do
    map |> Enum.reduce(%{}, fn {key, val}, acc -> Map.put(acc, to_string(key), val) end)
  end
end
