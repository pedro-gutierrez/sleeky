defmodule SleekiTest do
  use ExUnit.Case
  doctest Sleeki

  test "greets the world" do
    assert Sleeki.hello() == :world
  end
end
