defmodule Sleeky.ScopeTest do
  use ExUnit.Case

  alias Blogs.Accounts.Scopes.SelfAndNotLocked

  describe "allowed?/1" do
    test "returns true when all sub scopes are verified, and the operation is all" do
      context = %{current_user: %{id: 1}, user: %{id: 1, locked: false}}

      assert SelfAndNotLocked.allowed?(context)
    end

    test "returns false when some sub scopes is not verified, and the operation is all" do
      context = %{current_user: %{id: 1}, user: %{id: 1, locked: true}}

      refute SelfAndNotLocked.allowed?(context)
    end
  end
end
