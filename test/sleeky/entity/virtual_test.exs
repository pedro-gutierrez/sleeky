defmodule Sleeky.Entity.VirtualTest do
  use ExUnit.Case

  alias Blogs.Notifications.Digest

  describe "entities" do
    test "can be virtual" do
      assert Digest.virtual?()
    end

    test "have a name" do
      assert :digest == Digest.name()
    end
  end
end
