defmodule Sleeky.Model.KeyTest do
  use ExUnit.Case

  alias Blogs.Publishing.{Blog, Theme}
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
      assert [key] = Theme.keys()
      assert key.unique?
    end

    test "have primary keys of type binary_id" do
      pk = User.primary_key()
      assert :id == pk.name
      assert :id == pk.kind
      assert :binary_id == pk.storage
    end
  end
end
