defmodule Sleeky.Entity.PrimaryKeyTest do
  use ExUnit.Case
  import MigrationHelper

  alias TestApp.Schema.{Blog, User, Topic}

  describe "entity primary keys" do
    test "are uuids by default" do
      pk = User.primary_key()
      assert :id == pk.name
      assert :id == pk.kind
      assert :binary_id == pk.storage
    end

    test "can also be integers" do
      pk = Topic.primary_key()
      assert :id == pk.name
      assert :integer == pk.kind
      assert :integer == pk.storage
    end

    test "can also be strings " do
      pk = Blog.primary_key()
      assert :id == pk.name
      assert :string == pk.kind
      assert :string == pk.storage
    end

    test "are also attributes" do
      assert Blog.attributes() |> Enum.find(&(&1.name == :id))
      assert Topic.attributes() |> Enum.find(&(&1.name == :id))
      assert User.attributes() |> Enum.find(&(&1.name == :id))
    end

    test "are included in migrations" do
      migration = generate_migration()
      assert migration =~ "add(:id, :integer, primary_key: true, null: false)"
      assert migration =~ "add(:id, :string, primary_key: true, null: false)"
      assert migration =~ "add(:id, :binary_id, primary_key: true, null: false)"
    end

    test "have the correct data type in parent foreign keys" do
      migration = generate_migration()
      assert migration =~ "add(:blog_id, :string, null: false)"
      assert migration =~ "add(:user_id, :binary_id, null: false)"
    end
  end
end
