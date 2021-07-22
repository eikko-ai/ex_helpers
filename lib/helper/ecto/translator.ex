defmodule Helper.Translator do
  @moduledoc """
  The Translator Helper provides a way to provide translation for Ecto Schema fields
  without the need to create extra tables by using a map (PostgreSQL JSONB datatype)
  to embed locales / translations into the Ecto schema.

  This module improves on this idea by making use of some Macros and utilities created
  originally in the Elixir library [trans](https://github.com/crbelaus/trans/) by
  `crbelaus`.

  **Important**: Since the Ecto map datatype maps to a JSONB column (on PostgreSQL)
  this will only be supported on databases that can make use of this Ecto datatype.

  To use the Translator you need to require (use) the module in your Module and passing
  the fields to be translated.

  ## Example:

      defmodule Article do
        use Ecto.Schema
        use Helper.Translator, translate: [:title, :body]

        schema "articles" do
          field :title, :string
          field :body, :text
          field :translations, :map
        end
      end

  When used, `Translator` will define a `__trans__` function that can be used for
  runtime introspection of the translation metadata.

  By default, `Translator` stores and looks for translations in a field named
  `translations`. This field is known as the translations container. To change
  the default `:translations` container field name, pass the desired name when using the
  Translator module.

        use Translator, translate: [:title, :body], container: :locales
  """

  defmacro __using__(opts) do
    quote do
      Module.put_attribute(__MODULE__, :trans_fields, unquote(translatable_fields(opts)))
      Module.put_attribute(__MODULE__, :trans_container, unquote(translation_container(opts)))

      @after_compile {unquote(__MODULE__), :__validate_translatable_fields__}
      @after_compile {unquote(__MODULE__), :__validate_translation_container__}

      @spec __trans__(:fields) :: list(atom)
      def __trans__(:fields), do: @trans_fields

      @spec __trans__(:container) :: atom
      def __trans__(:container), do: @trans_container
    end
  end

  @doc """
  Get a translated value into the given locale or falls back to the default
  value if there is no translation available.

  ## Example
      iex> Helper.Translator.translate(article, :title, :pt)
      iex> "Olá Mundo!"
  """
  @spec translate(struct, atom, String.t() | atom) :: any
  def translate(%{__struct__: module} = struct, field, locale)
      when (is_binary(locale) or is_atom(locale)) and is_atom(field) do
    unless translatable?(struct, field) do
      raise "'#{inspect(module)}' module must declare '#{inspect(field)}' as translatable"
    end

    # Return the translation or fall back to the default value
    case translated_field(struct, locale, field) do
      :error -> Map.fetch!(struct, field)
      translation -> translation
    end
  end

  defp translated_field(%{__struct__: module} = struct, locale, field) do
    with {:ok, all_translations} <- Map.fetch(struct, module.__trans__(:container)),
         {:ok, translations_for_locale} <- Map.fetch(all_translations, to_string(locale)),
         {:ok, translated_field} <- Map.fetch(translations_for_locale, to_string(field)) do
      translated_field
    end
  end

  @doc """
  Checks whether the given field is translatable or not.

  **Important:** This function will raise an error if the given module does
  not use `Helper.Translator`.

      defmodule Article do
        use Ecto.Schema
        use Helper.Translator, translate: [:title, :body]

        schema "articles" do
          field :title, :string
          field :body, :string
          field :translations, :map
        end
      end

  If we want to know whether a certain field is translatable or not we can use
  this function as follows (we can also pass a struct instead of the module
  name itself):

      iex> Helper.Translator.translatable?(Article, :title)
      true
      iex> Helper.Translator.translatable?(%Article{}, :not_existing)
      false
  """
  @spec translatable?(module | struct, String.t() | atom) :: boolean
  def translatable?(%{__struct__: module}, field), do: translatable?(module, field)

  def translatable?(module_or_struct, field)
      when is_atom(module_or_struct) and is_binary(field) do
    translatable?(module_or_struct, String.to_atom(field))
  end

  def translatable?(module_or_struct, field) when is_atom(module_or_struct) and is_atom(field) do
    if Keyword.has_key?(module_or_struct.__info__(:functions), :__trans__) do
      Enum.member?(module_or_struct.__trans__(:fields), field)
    else
      raise "#{module_or_struct} must use `Helper.Translator` in order to be translated"
    end
  end

  @doc false
  def __validate_translatable_fields__(%{module: module}, _bytecode) do
    struct_fields =
      module.__struct__()
      |> Map.keys()
      |> MapSet.new()

    translatable_fields =
      :fields
      |> module.__trans__
      |> MapSet.new()

    invalid_fields = MapSet.difference(translatable_fields, struct_fields)

    case MapSet.size(invalid_fields) do
      0 ->
        nil

      1 ->
        raise ArgumentError,
          message:
            "#{module} declares '#{MapSet.to_list(invalid_fields)}' as translatable but it is not defined in the module's struct"

      _ ->
        raise ArgumentError,
          message:
            "#{module} declares '#{MapSet.to_list(invalid_fields)}' as translatable but it they not defined in the module's struct"
    end
  end

  @doc false
  def __validate_translation_container__(%{module: module}, _bytecode) do
    container = module.__trans__(:container)

    unless Enum.member?(Map.keys(module.__struct__()), container) do
      raise ArgumentError,
        message:
          "The field #{container} used as the translation container is not defined in #{module} struct"
    end
  end

  defp translatable_fields(opts) do
    case Keyword.fetch(opts, :translate) do
      {:ok, fields} when is_list(fields) ->
        fields

      _ ->
        raise ArgumentError,
          message:
            "Translator requires a 'translate' option that contains the list of translatable fields names"
    end
  end

  defp translation_container(opts) do
    case Keyword.fetch(opts, :container) do
      :error -> :translations
      {:ok, container} -> container
    end
  end
end
