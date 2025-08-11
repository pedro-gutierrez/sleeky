defmodule Sleeky.ModelTest do
  use ExUnit.Case

  alias Blogs.Accounts.User

  describe "describe field/1" do
    test "finds built-in fields" do
      assert {:ok, field} = User.field(:inserted_at)
      assert field.name == :inserted_at
    end
  end
end
