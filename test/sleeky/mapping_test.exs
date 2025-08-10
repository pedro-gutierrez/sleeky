defmodule Sleeky.MappingTest do
  use ExUnit.Case

  alias Blogs.Accounts.Mappings.UserToRegisteredUser
  alias Blogs.Accounts.User
  alias Blogs.Accounts.Events.UserRegistered

  describe "mapping metadata" do
    test "returns the source module" do
      assert UserToRegisteredUser.from() == User
    end

    test "returns the target module" do
      assert UserToRegisteredUser.to() == UserRegistered
    end

    test "returns the mapping name" do
      assert UserToRegisteredUser.name() == UserToRegisteredUser
    end

    test "returns the feature module" do
      feature = UserToRegisteredUser.feature()
      assert is_atom(feature)
      # The feature should be derived from the module path
      assert feature == Blogs.Accounts
    end

    test "returns the field mappings" do
      fields = UserToRegisteredUser.fields()
      assert is_list(fields)
      assert length(fields) == 2

      # Check that all expected fields are present
      field_names = Enum.map(fields, & &1.name)
      assert :user_id in field_names
      assert :registered_at in field_names

      # Check field paths
      user_id_field = Enum.find(fields, & &1.name == :user_id)
      assert user_id_field.expression == {:path, [:id]}

      registered_at_field = Enum.find(fields, & &1.name == :registered_at)
      assert registered_at_field.expression == {:path, [:inserted_at]}
    end
  end

  describe "map/1" do
    test "maps a complete user struct to registered user data" do
      user_data = %{
        "id" => "123",
        "email" => "user@example.com",
        "inserted_at" => ~N[2023-01-01 12:00:00],
        "public" => true,
        "external_id" => "ext_456"
      }

      result = UserToRegisteredUser.map(user_data)

      assert %UserRegistered{} = result
      assert result.user_id == "123"
      assert result.registered_at == ~N[2023-01-01 12:00:00]
    end

    test "handles missing optional fields gracefully" do
      user_data = %{
        "id" => "123",
        "email" => "user@example.com",
        "inserted_at" => ~N[2023-01-01 12:00:00]
      }

      result = UserToRegisteredUser.map(user_data)

      assert %UserRegistered{} = result
      assert result.user_id == "123"
      assert result.registered_at == ~N[2023-01-01 12:00:00]
    end

    test "handles empty data" do
      result = UserToRegisteredUser.map(%{})

      assert %UserRegistered{} = result
      assert result.user_id == nil
      assert result.registered_at == nil
    end

    test "handles nil data" do
      result = UserToRegisteredUser.map(nil)

      assert %UserRegistered{} = result
      assert result.user_id == nil
      assert result.registered_at == nil
    end

    test "handles string keys in source data" do
      user_data = %{
        "id" => "string_id",
        "email" => "test@example.com",
        "inserted_at" => ~N[2023-01-01 12:00:00]
      }

      result = UserToRegisteredUser.map(user_data)

      assert %UserRegistered{} = result
      assert result.user_id == "string_id"
      assert result.registered_at == ~N[2023-01-01 12:00:00]
    end

    test "handles atom keys in source data" do
      user_data = %{
        id: "atom_id",
        email: "test@example.com",
        inserted_at: ~N[2023-01-01 12:00:00]
      }

      result = UserToRegisteredUser.map(user_data)

      assert %UserRegistered{} = result
      assert result.user_id == "atom_id"
      assert result.registered_at == ~N[2023-01-01 12:00:00]
    end
  end
end
