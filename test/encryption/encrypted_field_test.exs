defmodule Encryption.EncryptedFieldTest do
  use ExUnit.Case

  alias Helper.Encryption.EncryptedField, as: Field

  @keys "JTxv4iSknKWqaxBMX41ifenxj5Url+0jzMdV5Vxf5fQ="

  setup_all do
    Application.put_env(:ex_helpers, Encryption.AES, keys: @keys)
  end

  test "type/0 is :binary" do
    assert Field.type() == :binary
  end

  test "cast/1 converts a value to a string" do
    assert {:ok, "123"} == Field.cast(123)
  end

  test "dump/1 encrypts a value" do
    {:ok, ciphertext} = Field.dump("hello")

    assert ciphertext != "hello"
    assert String.length(ciphertext) != 0
  end
end
