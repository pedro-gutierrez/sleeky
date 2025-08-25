defmodule Sleeky.EventTest do
  use ExUnit.Case

  alias Blogs.Accounts.Events.UserRegistered
  alias Blogs.Accounts.Events.UsersLocked

  describe "new/1" do
    test "creates event with valid required data" do
      now = DateTime.utc_now()

      params = %{
        user_id: Ecto.UUID.generate(),
        registered_at: now
      }

      {:ok, event} = UserRegistered.new(params)

      assert event.user_id == params.user_id
      assert event.registered_at == now
    end

    test "support fields that are lists of values" do
      user_ids = ["1", "2"]
      params = [user_ids: user_ids]

      {:ok, event} = UsersLocked.new(params)

      assert event.user_ids == user_ids
    end
  end
end
