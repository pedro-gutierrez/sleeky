defmodule Sleeky.Model.CreateTest do
  use Sleeky.DataCase

  alias Blogs.Publishing.Author

  describe "create function" do
    test "creates models and inlined children" do
      attrs = %{
        "id" => Ecto.UUID.generate(),
        "name" => "john",
        "blogs" => [
          %{
            "id" => Ecto.UUID.generate(),
            "name" => "personal blog",
            "published" => true,
            "posts" => [
              %{
                "id" => Ecto.UUID.generate(),
                "title" => "hello world",
                "locked" => false,
                "published" => true,
                "deleted" => false,
                "published_at" => DateTime.utc_now()
              }
            ]
          }
        ]
      }

      assert {:ok, author} = Author.create(attrs)
      assert [blog] = author.blogs
      assert [_post] = blog.posts
    end
  end
end
