defmodule Helper.Ecto do
  @moduledoc """
  Helper functions to work with Ecto.
  """

  alias Ecto.Changeset

  @type t(data_type) :: %Changeset{
          valid?: boolean(),
          repo: atom | nil,
          repo_opts: Keyword.t(),
          data: data_type,
          params: %{optional(String.t()) => term} | nil,
          changes: %{optional(atom) => term},
          required: [atom],
          prepare: [(t -> t)],
          errors: [{atom, error}],
          constraints: [constraint],
          validations: [{atom, term}],
          filters: %{optional(atom) => term},
          action: action,
          types: nil | %{atom => Ecto.Type.t()}
        }

  @type t :: t(Ecto.Schema.t() | map | nil)
  @type error :: {String.t(), Keyword.t()}
  @type action :: nil | :insert | :update | :delete | :replace | :ignore | atom
  @type constraint :: %{
          type: :check | :exclusion | :foreign_key | :unique,
          constraint: String.t(),
          match: :exact | :suffix | :prefix,
          field: atom,
          error_message: String.t(),
          error_type: atom
        }

  ## Query

  @doc """
  Transform column to lowercase.
  """
  defmacro upper(arg) do
    quote do
      fragment("upper(?)", unquote(arg))
    end
  end

  @doc """
  Transform column to uppercase.
  """
  defmacro lower(arg) do
    quote do
      fragment("lower(?)", unquote(arg))
    end
  end

  ## Changesets

  @doc """
  Convertes the changeset fields to lowercase. This is useful if for some reason
  we can't use (field is encrypted for example) something like citext (PostgreSQL extension)
  for fields that we want to enforce as case invariance, for instance an email field.

  ## Examples

      iex> changeset = change(%Post{body: "foo"}, %{title: "Bar"})
      iex> downcase_change(changeset, :title)
      iex> changeset.change.title
      iex> "bar"
  """
  @spec downcase_change(t, list | atom) :: t
  def downcase_change(%Changeset{} = changeset, fields) when not is_nil(fields) do
    changes = get_downcased_changes(changeset, fields)
    Changeset.change(changeset, changes)
  end

  @spec get_downcased_changes(t, list | atom) :: [{atom, term}]
  defp get_downcased_changes(changeset, fields) do
    for field <- List.wrap(fields) do
      change = Changeset.get_change(changeset, field)

      if change do
        {field, String.downcase(change)}
      else
        {field, nil}
      end
    end
  end

  @doc """
  Transform `%Ecto.Changeset{}` errors to a map
  containing field name as a key on which validation
  error happened and it's formatted message.
  For example:
  ```
  %{
    "title": "title length should be at least 8 characters"
    ...
  }
  ```
  """
  @spec changeset_error_details(t) :: t
  def changeset_error_details(%Changeset{} = changeset) do
    changeset
    |> transform_errors()
    |> concat_errors()
  end

  # Helper to transform changeset errors into structured
  # error data.
  @spec transform_errors(t) :: %{required(atom) => [String.t() | map]}
  def transform_errors(%Changeset{} = changeset) do
    changeset
    |> Changeset.traverse_errors(&format_error/1)
  end

  # Helper to format a changeset error message.
  defp format_error({message, opts}) do
    Regex.replace(~r"%{(\w+)}", message, fn _, key ->
      opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
    end)
  end

  # Get all errors from `transform_errors/1`
  # and join their messages into a single string
  # separated by ","
  defp concat_errors(errors) do
    Enum.reduce(errors, errors, fn {key, value}, map ->
      map |> Map.put(key, Enum.join(value, ", "))
    end)
  end

  @doc """
  Serializes the error map produced by format_changeset_errors
  into a list of strings.

  For example:
  ```
  [
  "email: has already been taken;",
  "password: should be at least 12 character(s);,"
  ...
  ]
  ```
  """
  def serialize_errors(errors_map) do
    errors_map
    |> Enum.map(fn {key, error} ->
      "#{key}: #{Enum.join(error, ", ")};"
    end)
  end

  ## Migrations

  @doc """
  Macro to create an ENUM TYPE in an Ecto migration file.

  Example:
  ```
    create_enum("user_role", "'admin', 'staff', 'user'")
  ```
  """
  defmacro create_enum(type, values) do
    quote do
      execute(
        unquote("CREATE TYPE #{type} AS ENUM (#{values})"),
        unquote("DROP TYPE #{type}")
      )
    end
  end
end
