defmodule Helper.ErrorHandler do
  @moduledoc """
  This module defines some helper function used by
  handle/format changeset errors
  """

  def translator do
    Helper.gettext()
  end

  def not_found_formater(queryable, id) when is_integer(id) or is_binary(id) do
    modal = queryable |> to_string |> String.split(".") |> List.last()

    translator() |> Gettext.dgettext("404", "#{modal}(%{id}) not found", id: id)
  end

  def not_found_formater(queryable, clauses) do
    modal = queryable |> to_string |> String.split(".") |> List.last()

    detail =
      clauses
      |> Enum.into(%{})
      |> Map.values()
      |> List.first()
      |> to_string

    translator() |> Gettext.dgettext("404", "#{modal}(%{name}) not found", name: detail)
  end
end
