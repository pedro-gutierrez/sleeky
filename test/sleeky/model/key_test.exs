defmodule Sleeky.Model.KeyTest do
  use ExUnit.Case

  alias Blogs.Publishing.{Blog, Topic}
  alias Blogs.Accounts.User
  alias Sleeky.Model.{Attribute, Relation}

  describe "models" do
    test "have keys as a combination of fields" do
      assert [key] = Blog.keys()
      assert Blog == key.model
      assert [%Relation{name: :author}, %Attribute{name: :name}] = key.fields
      assert key.unique?
    end

    test "can have unique keys" do
      assert [key] = Topic.keys()
      assert key.unique?
    end

    test "have a primary a uuid primary key" do
      pk = User.primary_key()
      assert :id == pk.name
      assert :id == pk.kind
      assert :binary_id == pk.storage
    end

    test "can have an integer primary key" do
      pk = Topic.primary_key()
      assert :id == pk.name
      assert :integer == pk.kind
      assert :integer == pk.storage
    end

    test "can have a string primary key" do
      assert %Attribute{} = pk = Blog.primary_key()
      assert :id == pk.name
      assert :string == pk.kind
      assert :string == pk.storage
    end
  end
end
