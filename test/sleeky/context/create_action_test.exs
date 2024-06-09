defmodule Sleeky.Context.CreateActionTest do
  use Sleeky.DataCase

  alias Blogs.Publishing

  setup [:comments, :current_user]

  describe "create action" do
    test "requires an id", context do
      params = %{id: uuid(), name: "author"}
      ctx = guest(context).params

      assert {:ok, author} = Publishing.create_author(params, ctx)
      assert author.id == params.id
      assert author.name == params.name
    end

    test "requires parent relations", context do
      params = %{id: uuid(), name: "blog", published: true, author: context.author}
      ctx = author(context).params

      assert {:ok, blog} = Publishing.create_blog(params, ctx)
      assert blog.author_id == context.author.id
    end

    test "creates children too", context do
      params = %{
        id: uuid(),
        name: "author",
        blogs: [
          %{id: uuid(), name: "my blog", published: true}
        ]
      }

      ctx = guest(context).params

      assert {:ok, author} = Publishing.create_author(params, ctx)
      assert [blog] = author.blogs
      assert blog.name == "my blog"
    end
  end
end
