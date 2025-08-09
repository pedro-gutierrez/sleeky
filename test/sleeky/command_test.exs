defmodule Sleeky.CommandTest do
  use ExUnit.Case

  alias Blogs.Accounts.Commands.{RemindPassword, RegisterUser}

  describe "allowed?/1" do
    test "always allows if the command has no policies" do
      context = %{current_user: %{roles: []}}

      assert RemindPassword.allowed?(context)
    end

    test "denies if no policies match the current subject" do
      context = %{current_user: %{roles: [:admin]}}

      refute RegisterUser.allowed?(context)
    end

    test "allows if the role is matched and no scope is defined" do
      context = %{current_user: %{roles: [:guest]}}

      assert RegisterUser.allowed?(context)
    end

    test "allows if the role is matched and the scope also matches" do
      context = %{
        current_user: %{id: 1, roles: [:user]},
        user: %{id: 1, locked: false}
      }

      assert RemindPassword.allowed?(context)
    end

    test "denies if the role is matched but the scope doesn't" do
      context = %{
        current_user: %{id: 1, roles: [:user]},
        user: %{id: 1, locked: true}
      }

      refute RemindPassword.allowed?(context)
    end
  end
end
