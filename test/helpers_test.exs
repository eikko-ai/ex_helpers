defmodule HelpersTest do
  use ExUnit.Case
  doctest Helpers

  test "greets the world" do
    assert Helpers.hello() == :world
  end
end
