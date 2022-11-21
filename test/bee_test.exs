defmodule BeeTest do
  use ExUnit.Case
  doctest Bee

  test "greets the world" do
    assert Bee.hello() == :world
  end
end
