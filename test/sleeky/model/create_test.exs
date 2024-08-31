defmodule Sleeky.Model.CreateTest do
  use Sleeky.DataCase

  alias Blogs.Publishing.Author
  alias Blogs.Publishing.Theme

  describe "create function" do
    test "creates models" do
      attrs = %{
        "id" => Ecto.UUID.generate(),
        "name" => "john"
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
  end
end
