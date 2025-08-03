defmodule Sleeky.Entity.CreateTest do
  use Sleeky.DataCase

  alias Blogs.Accounts.User
  alias Blogs.Publishing.Author
  alias Blogs.Publishing.Theme

  describe "create function" do
    test "creates entities" do
      attrs = %{
        "id" => Ecto.UUID.generate(),
        "name" => "john"
      }

      assert {:ok, author} = Author.create(attrs)
      assert author.name == "john"
    end

    test "supports attributes as keyword lists" do
      assert {:ok, author} = Author.create(id: Ecto.UUID.generate(), name: "john")
      assert author.name == "john"
    end

    test "support attribute with atom keys" do
      attrs = %{
        id: Ecto.UUID.generate(),
        name: "john"
      }

      assert {:ok, author} = Author.create(attrs)
      assert author.name == "john"
    end

    test "validates inclusion of attribute values" do
      attrs = %{
        "id" => Ecto.UUID.generate(),
        "name" => "other"
      }

      assert {:error, changeset} = Theme.create(attrs)
      assert errors_on(changeset) == %{name: ["is invalid"]}
    end

    test "validates ids" do
      attrs = %{
        external_id: "1",
        email: "foo@bar.com",
        id: "2"
      }

      assert {:error, changeset} = User.create(attrs)

      assert errors_on(changeset) == %{
               external_id: ["is not a valid UUID"],
               id: ["is not a valid UUID"]
             }
    end
  end

  describe "create_many/2" do
    test "creates many entities at once" do
      authors = [%{name: "a1", profile: "publisher"}, %{name: "a2", profile: "publisher"}]

      assert :ok = Author.create_many(authors)
    end
  end
end
