defmodule Sleeky.CommandTest do
  use Sleeky.DataCase

  alias Blogs.Accounts.Commands.{RemindPassword, RegisterUser}
  alias Blogs.Accounts.User
  alias Blogs.Accounts.Values.UserId
  alias Blogs.Accounts.Events.UserRegistered

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

  describe "execute/2" do
    test "returns a result and a list of events" do
      params = %User{id: uuid(), email: "test@gmail.com", external_id: uuid()}
      context = %{}

      assert {:ok, user, [event]} = RegisterUser.execute(params, context)

      assert user.id == params.id
      assert user.email == params.email

      assert %UserRegistered{} = event
      assert event.user_id == user.id
      assert event.registered_at == user.inserted_at
    end

    test "returns the input params by default" do
      params = %UserId{user_id: uuid()}
      context = %{}

      assert {:ok, result, events} = RemindPassword.execute(params, context)
      assert result == params
      assert events == []
    end
  end
end
