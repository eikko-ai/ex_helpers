defmodule Helper.Files do
  @moduledoc """
  Utilities related file manipulation.
  """

  @doc """
  Helper to create a file (along with its parent dir) and write
  the content to the created file
  """
  @spec create_and_write(Path.t(), iodata()) :: Path.t()
  def create_and_write(file_path, content) do
    File.mkdir_p!(Path.dirname(file_path))
    File.write!(file_path, content)
    file_path
  end

  @doc false
  def unzip_file(archive, target_dir) do
    file = String.to_charlist(archive)
    dir = String.to_charlist(target_dir)

    case :zip.unzip(file, [{:cwd, dir}]) do
      {:ok, file_list} -> {:ok, file_list}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Decode / deserialized the JSON datafile.

  ## Example
  iex> Helper.Files.decode_json("knowledge/skills.json")
  """
  def decode_json(file_path) do
    file_path
    |> File.read!()
    |> Jason.decode!()
  end

  @doc """
  Returns the absolute path of `file_path` relative to the
  application data dir (priv/data).
  """
  def datafile_path(file_path) do
    Helper.Utils.get_config(:general, :data_dir)
    |> Path.absname()
    |> Path.join(file_path)
  end
end
