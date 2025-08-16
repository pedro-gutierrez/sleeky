defmodule Sleeky.EventTest do
  use ExUnit.Case

  alias Blogs.Accounts.Events.UserRegistered

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
  end
end
