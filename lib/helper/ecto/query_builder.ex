defmodule Helper.QueryBuilder do
  import Ecto.Query, warn: false

  @moduledoc """
  Common use case queries.
  """

  @doc """
  Handle dynamic query filters helper.
  Filters are passed in a map.

  Example:
    filter_with(User, %{filter: %{role: [%{eq: "admin"}]}})
  """
  def filter_with(query, %{filter: filters}) when is_map(filters) do
    filters
    |> Map.to_list()
    |> Enum.reduce(query, fn
      {_key, val}, query when val in [nil, ""] ->
        query

      {field_name, exps}, query ->
        filter_where(query, field_name, exps)
    end)
  end

  def filter_with(query, _), do: query

  # Filter queryable with where clause on column (key) with
  # with the passed operator expressions
  defp filter_where(query, field_name, exps) when is_list(exps) do
    exps
    |> Enum.reduce(query, fn
      %{eq: value}, query ->
        from q in query, where: field(q, ^field_name) == ^value

      %{neq: value}, query ->
        from q in query, where: field(q, ^field_name) != ^value

      %{gt: value}, query ->
        from q in query, where: field(q, ^field_name) > ^value

      %{lt: value}, query ->
        from q in query, where: field(q, ^field_name) < ^value

      %{gte: value}, query ->
        from q in query, where: field(q, ^field_name) >= ^value

      %{lte: value}, query ->
        from q in query, where: field(q, ^field_name) <= ^value

      %{in: value}, query ->
        from q in query, where: field(q, ^field_name) in ^value

      %{nin: value}, query ->
        from q in query, where: field(q, ^field_name) not in ^value

      {_, _}, query ->
        query
    end)
  end

  defp filter_where(query, _, _), do: query

  @doc """
  Generic sorting (order_by) helper. Sorters is an Ecto order_by
  compatible Keyword list of bindings.
  See: https://hexdocs.pm/ecto/Ecto.Query.html#order_by/3
  """
  def sort_by(query, %{sorter: sorters}) when is_map(sorters) do
    with sort_list <-
           sorters
           |> Map.to_list()
           |> Enum.map(fn {key, val} -> {val, key} end) do
      from q in query, order_by: ^sort_list
    end
  end

  def sort_by(query, _), do: query

  @doc """
  Build a search on an Ecto queryable with the provided keyword search
  filter clauses.

  Example: search(Dish, name: "Hot Dogs", description: "delicious")
  """
  def search_query(queryable, clauses) do
    Enum.reduce(clauses, queryable, fn {key, value}, queryable ->
      from q in queryable, or_where: ilike(field(q, ^key), ^value)
    end)
  end
end
