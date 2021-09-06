defmodule Helper.Encryption.AES do
  @moduledoc """
  Encrypt values with AES in Galois/Counter Mode (GCM)
  https://en.wikipedia.org/wiki/Galois/Counter_Mode
  using a random Initialisation Vector for each encryption,
  this makes "bruteforce" decryption much more difficult.
  See `encrypt/1` and `decrypt/1` for more details.

  Source: https://github.com/dwyl/phoenix-ecto-encryption-example
  """

  @type plaintext :: binary
  @type ciphertext :: binary

  # Use AES 256 Bit Keys for Encryption.
  @aad "AES256GCM"
  @iv_length 12

  @doc """
  Encrypt Using AES Galois/Counter Mode (GCM)
  https://en.wikipedia.org/wiki/Galois/Counter_Mode
  Uses a random IV for each call, and prepends the IV and Tag to the
  ciphertext.  This means that `encrypt/1` will never return the same ciphertext
  for the same value. This makes "cracking" (bruteforce decryption) much harder!

  ## Parameters
  - `plaintext`: Accepts any data type as all values are converted to a String
    using `to_string` before encryption.

  ## Examples
      iex> Encryption.AES.encrypt("tea") != Encryption.AES.encrypt("tea")
      true
      iex> ciphertext = Encryption.AES.encrypt(123)
      iex> is_binary(ciphertext)
      true
  """
  @spec encrypt(plaintext) :: binary
  def encrypt(plaintext) do
    key = get_key()
    key_id = get_key_id()
    iv = :crypto.strong_rand_bytes(@iv_length)

    {ciphertext, ciphertag} = do_encrypt(key, iv, plaintext)
    iv <> ciphertag <> <<key_id::unsigned-big-integer-32>> <> ciphertext
  end

  # Remove this once support for Erlang/OTP 21 is dropped.
  defp do_encrypt(key, iv, plaintext) do
    :crypto.crypto_one_time_aead(:aes_256_gcm, key, iv, to_string(plaintext), @aad, true)
  end

  @doc """
  Decrypt a binary using GCM.

  ## Parameters
  - `ciphertext`: a binary to decrypt, assuming that the first 16 bytes of the
    binary are the IV to use for decryption.
  - `key_id`: the index of the AES encryption key used to encrypt the ciphertext

  ## Example
      iex> Encryption.AES.encrypt("test") |> Encryption.AES.decrypt()
      "test"
  """
  @spec decrypt(ciphertext) :: binary
  def decrypt(ciphertext) do
    <<iv::binary-size(@iv_length), ciphertag::binary-16, key_id::unsigned-big-integer-32,
      ciphertext::binary>> = ciphertext

    do_decrypt(get_key(key_id), iv, ciphertext, ciphertag)
  end

  # Remove this once support for Erlang/OTP 21 is dropped.
  defp do_decrypt(key, iv, ciphertext, ciphertag) do
    :crypto.crypto_one_time_aead(:aes_256_gcm, key, iv, ciphertext, @aad, ciphertag, false)
  end

  # @doc """
  # get_key - Get encryption key from list of keys.
  # if `key_id` is *not* supplied as argument,
  # then the default *latest* encryption key will be returned.

  # ## Parameters
  # - `key_id`: the index of AES encryption key used to encrypt the ciphertext
  @spec get_key() :: binary
  defp get_key do
    get_key_id() |> get_key
  end

  @spec get_key(number) :: binary
  defp get_key(key_id) do
    encryption_keys() |> Enum.at(key_id)
  end

  @spec get_key_id() :: integer()
  defp get_key_id do
    Enum.count(encryption_keys()) - 1
  end

  @spec encryption_keys() :: list(binary)
  defp encryption_keys do
    case keys = Application.get_env(:ex_helpers, Encryption.AES)[:keys] do
      k when is_binary(k) ->
        keys
        |> String.replace("'", "")
        |> String.split(",")
        |> Enum.map(&:base64.decode(&1))

      _ ->
        raise("""
        environment variable ENCRYPTION_KEYS is missing.
        You can generate one by calling: mix helper.gen.encryption
        """)
    end
  end
end
