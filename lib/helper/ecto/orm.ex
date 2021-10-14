defmodule Helper.ORM do
  @moduledoc """
  General CRUD functions
  """

  import Ecto.Query, warn: false
  import Ecto, only: [assoc: 2]
  import Helper.Utils, only: [done: 1, done: 3]
  import Helper.ErrorHandler

  alias Helper.QueryBuilder

  @doc """
  Paginate wrapper
  """
  def paginator(query, %{pagination: %{page: page, size: size}}) do
    query |> Helper.repo().paginate(page: page, page_size: size)
  end

  def paginator(query, %{page: page, size: size}) do
    query |> Helper.repo().paginate(page: page, page_size: size)
  end

  def paginator(query, page: page, size: size) do
    query |> Helper.repo().paginate(page: page, page_size: size)
  end

  def paginator(query, _), do: query

  @doc """
  Repo.all/1 with error handling
  """
  def list(query) do
    query
    |> Helper.repo().all()
    |> done()
  end

  @doc """
  Find all of query, filtered, sorted, and with error handling.

   Example:
    find_all(User, %{filter: %{role: [%{eq: "admin"}]}})
  """
  def find_all(query, attrs) do
    query
    |> QueryBuilder.filter_with(attrs)
    |> QueryBuilder.sort_by(attrs)
    |> Helper.repo().all()
    |> done()
  end

  def find_all(query), do: list(query)

  @doc """
  Find all of query, paginated, filtered, sorted, and with error handling.
  """
  def list_paginated(query, %{pagination: pagination} = attrs) do
    query
    |> QueryBuilder.filter_with(attrs)
    |> QueryBuilder.sort_by(attrs)
    |> paginator(pagination)
    |> done()
  end

  def list_paginated(query, attrs) do
    query
    |> QueryBuilder.filter_with(attrs)
    |> QueryBuilder.sort_by(attrs)
    |> Helper.repo().paginate()
    |> done()
  end

  def list_paginated(query) do
    query
    |> Helper.repo().paginate()
    |> done()
  end

  @doc """
  Similar to Repo.get/3, with standard result/error handle
  """
  def find(query, id) do
    query
    |> Helper.repo().get(id)
    |> done(query, id)
  end

  @doc """
  Wrap Repo.get with preload and result/errer format handle
  """
  def find(query, id, preload: preload) do
    query
    |> preload(^preload)
    |> Helper.repo().get(id)
    |> done(query, id)
  end

  @doc """
  Similar to Repo.get_by/3, with standard result/error handle
  """
  def find_by(query, clauses) do
    query
    |> Helper.repo().get_by(clauses)
    |> case do
      nil ->
        {:error, not_found_formater(query, clauses)}

      result ->
        {:ok, result}
    end
  end

  @doc """
  Preload using only one query by using join with preload.
  Source: https://gist.github.com/joshnuss/9c68ad2c2649b571dd241693dad6f6f6

  ## Example

      Invoice
      |> preloader(:customer)
      |> preloader(:lines)
      |> Repo.all()
  """
  defmacro preloader(query, association) do
    alias Ecto.Query.Builder.{Join, Preload}

    expr = quote do: assoc(l, unquote(association))
    binding = quote do: [l]
    preload_bindings = quote do: [{unquote(association), x}]
    preload_expr = quote do: [{unquote(association), x}]

    query
    |> Join.build(:left, binding, expr, nil, nil, association, nil, nil, __CALLER__)
    |> elem(0)
    |> Preload.build(preload_bindings, preload_expr, __CALLER__)
  end

  @doc """
  Return the total count of the Queryable based on the id.
  Can be filtered.

  Example:
    count(User)

    count(User, %{filter: %{role: [%{eq: "admin"}]}})
  """
  def count(queryable, attrs \\ %{}) do
    queryable
    |> QueryBuilder.filter_with(attrs)
    |> select([q], count(q.id))
    |> Helper.repo().one()
  end

  @doc """
  Search (where ilike) the term on the queryables list on
  the passed fields.

  Example: search([Country, Place], [:name, :description], "lisbon")
  """
  def search(queryables, fields, term) when is_list(queryables) do
    queryables
    |> Enum.flat_map(fn query ->
      fields_list = fields |> Enum.map(&{&1, "%#{term}%"})

      QueryBuilder.search_query(query, fields_list)
      |> Helper.repo().all()
    end)
  end

  def search(query, fields, term) do
    fields_list = fields |> Enum.map(&{&1, "%#{term}%"})

    QueryBuilder.search_query(query, fields_list)
    |> Helper.repo().all()
  end

  def get_random_db_entry(query) do
    query
    |> order_by(fragment("RANDOM()"))
    |> limit(1)
    |> Helper.repo().one()
  end
end
