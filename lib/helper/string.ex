defmodule Helper.String do
  @moduledoc false

  def pre_process(string) when is_binary(string) do
    string
    |> normalize_text()
    |> replace_punctuation()
    |> normalize_whitespace()
    |> String.downcase()
  end

  # erlang.org/doc/man/unicode.html#characters_to_nfkc_binary-1
  @spec normalize_text(binary()) :: binary()
  def normalize_text(string) when is_binary(string) do
    :unicode.characters_to_nfkc_binary(string)
  end

  # Replace spans of whitespace with a single space
  @spec normalize_whitespace(binary()) :: binary()
  def normalize_whitespace(string) when is_binary(string) do
    String.replace(string, ~r/\s+/u, " ") |> String.trim()
  end

  # Replace punctuation marks with spaces
  @spec replace_punctuation(binary()) :: binary()
  def replace_punctuation(string) when is_binary(string) do
    String.replace(string, ~r/[\p{P}\p{S}]/u, " ")
  end
end
