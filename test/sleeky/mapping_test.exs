defmodule Sleeky.MappingTest do
  use ExUnit.Case

  alias Blogs.Accounts.Mappings.UserRegisteredFromUser
  alias Blogs.Accounts.User
  alias Blogs.Accounts.Events.UserRegistered

  describe "map/1" do
    test "copies data from a source value to a target value" do
      now = DateTime.utc_now()

      data = %{
        "id" => Ecto.UUID.generate(),
        "inserted_at" => now,
      }

      assert {:ok, result} = UserRegisteredFromUser.map(data)

      assert %UserRegistered{} = result
      assert result.user_id == data["id"]
      assert result.registered_at == data["inserted_at"]
    end

    test "handles atom keys in source data" do
      now = DateTime.utc_now()

      data = %User{
        id: Ecto.UUID.generate(),
        inserted_at: now
      }

      assert {:ok, result} = UserRegisteredFromUser.map(data)

      assert %UserRegistered{} = result
      assert result.user_id == data.id
      assert result.registered_at == data.inserted_at
    end
  end
end
