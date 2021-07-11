defmodule Helper.Encryption.HashField do
  @behaviour Ecto.Type

  def type, do: :binary

  # cast/1 simply calls to_string on the value and returns a "success" tuple
  def cast(value) do
    {:ok, to_string(value)}
  end

  # dump/1 is called when the field value is about to be written to the database
  def dump(value) do
    {:ok, hash(value) |> :base64.encode()}
  end

  # load/1 is called when the field is loaded from the database
  def load(value) do
    {:ok, value}
  end

  def embed_as(_), do: :self

  def equal?(value1, value2), do: value1 == value2

  def hash(value) do
    :crypto.hash(:sha256, value <> get_salt(value))
  end

  # Get/use Phoenix secret_key_base as "salt" for one-way hashing Email address
  # use the *value* to create a *unique* "salt" for each value that is hashed:
  defp get_salt(value) do
    otp_app = Helper.otp_app()
    endpoint = Helper.endpoint()

    secret_key_base = Application.get_env(otp_app, endpoint)[:secret_key_base]
    :crypto.hash(:sha256, value <> secret_key_base)
  end
end
