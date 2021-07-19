defmodule Encryption.AESTest do
  use ExUnit.Case

  alias Helper.Encryption.AES

  doctest Helper.Encryption.AES

  @keys "JTxv4iSknKWqaxBMX41ifenxj5Url+0jzMdV5Vxf5fQ="

  setup_all do
    Application.put_env(:ex_helpers, Encryption.AES, keys: @keys)
  end

  describe "encrypt/1" do
    test "can encrypt a value" do
      assert AES.encrypt("hello") != "hello"
    end

    test "can encrypt a number" do
      assert is_binary(AES.encrypt(123))
    end

    test "includes the random IV in the value" do
      <<iv::binary-12, ciphertext::binary>> = AES.encrypt("hello")

      assert String.length(iv) != 0
      assert String.length(ciphertext) != 0
      assert is_binary(ciphertext)
    end

    test "includes the key_id in the value" do
      <<_iv::binary-12, _tag::binary-16, key_id::unsigned-big-integer-32, _ciphertext::binary>> =
        AES.encrypt("hello")

      assert key_id == 0
    end

    test "does not produce the same ciphertext twice" do
      assert AES.encrypt("hello") != AES.encrypt("hello")
    end
  end

  describe "decrypt/1" do
    test "can decrypt a value" do
      plaintext = "hello" |> AES.encrypt() |> AES.decrypt()
      assert plaintext == "hello"
    end

    test "can still decrypt the value after adding a new encryption key" do
      encrypted_value = "hello" |> AES.encrypt()

      # Add a new key
      new_key = :crypto.strong_rand_bytes(32) |> :base64.encode()
      Application.put_env(:iki, Encryption.AES, keys: "#{@keys},#{new_key}")

      assert "hello" == encrypted_value |> AES.decrypt()

      # # rollback to the original keys
      Application.put_env(:iki, Encryption.AES, keys: @keys)
    end
  end
end
