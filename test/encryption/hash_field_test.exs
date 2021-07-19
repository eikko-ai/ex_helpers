defmodule Encryption.HashFieldTest do
  use ExUnit.Case
  # our Ecto Custom Type for hashed fields
  alias Helper.Encryption.HashField, as: Field

  setup_all do
    Application.put_env(:ex_helpers, IkiWeb.Endpoint,
      secret_key_base: "Sh8I1hh3j3LdP9/bbES40O1OEyRTJ3pYsvh9DRmAUPGh6+qt5uG0O318OWm5YsO9"
    )
  end

  test "type/0 is :binary" do
    assert Field.type() == :binary
  end

  test "cast/1 converts a value to a string" do
    assert {:ok, "42"} == Field.cast(42)
    assert {:ok, "atom"} == Field.cast(:atom)
  end

  test "dump/1 converts a value to a sha256 hash" do
    {:ok, hash} = Field.dump("hello")

    assert :base64.decode(hash) ==
             <<179, 140, 111, 60, 222, 1, 243, 169, 189, 20, 102, 52, 85, 132, 36, 140, 186, 151,
               130, 143, 220, 112, 132, 247, 31, 8, 208, 159, 7, 237, 254, 140>>
  end

  test "hash/1 converts a value to a sha256 hash with secret_key_base as salt" do
    hash = Field.hash("nuno@iki.ai")

    assert hash ==
             <<173, 74, 155, 73, 247, 177, 107, 252, 28, 49, 132, 165, 171, 7, 235, 108, 136, 233,
               53, 125, 88, 224, 93, 58, 62, 111, 48, 40, 133, 227, 61, 197>>
  end

  test "load/1 does not modify the hash, since the hash cannot be reversed" do
    hash =
      <<16, 231, 67, 229, 9, 181, 13, 87, 69, 76, 227, 205, 43, 124, 16, 75, 46, 161, 206, 219,
        141, 203, 199, 88, 112, 1, 204, 189, 109, 248, 22, 254>>

    assert {:ok, ^hash} = Field.load(hash)
  end

  test "equal?/2 correctly determines hash equality and inequality" do
    hash1 =
      <<16, 231, 67, 229, 9, 181, 13, 87, 69, 76, 227, 205, 43, 124, 16, 75, 46, 161, 206, 219,
        141, 203, 199, 88, 112, 1, 204, 189, 109, 248, 22, 254>>

    hash2 =
      <<10, 231, 67, 229, 9, 181, 13, 87, 69, 76, 227, 205, 43, 124, 16, 75, 46, 161, 206, 219,
        141, 203, 199, 88, 112, 1, 204, 189, 109, 248, 22, 254>>

    assert Field.equal?(hash1, hash1)
    refute Field.equal?(hash1, hash2)
  end
end
