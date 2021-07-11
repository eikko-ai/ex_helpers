defmodule Mix.Tasks.Helper.Gen.Encryption do
  @shortdoc "Generates an AES-256 bit encryption key"

  @moduledoc """
  Generates a AES-256 bit encryption key.

      mix helper.gen.encryption -n 3

  ## Arguments
    * `--num` - the number of keys to generate. Defaults to 1
  """

  @switches [num: :integer]
  @default_opts [num: 1]

  use Mix.Task

  def run(args) do
    {[num: n], _, _} = parse_opts(args)

    for _ <- 1..n, do: IO.puts(generate_key())
  end

  defp generate_key, do: :crypto.strong_rand_bytes(32) |> :base64.encode()

  @doc false
  defp parse_opts(args) do
    {opts, parsed, invalid} = OptionParser.parse(args, switches: @switches)

    merged_opts =
      @default_opts
      |> Keyword.merge(opts)

    {merged_opts, parsed, invalid}
  end
end
