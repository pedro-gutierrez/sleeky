defmodule Sleeky.Model.ListTest do
  use Sleeky.DataCase

  alias Blogs.Publishing.{Blog, Comment}

  import Ecto.Query

  setup [:user, :comments]

  describe "list function" do
    test "returns all blogs by default", %{blog: blog} do
      assert page = Blog.list()
      assert page.metadata.total_count == 1

      assert [blog] == page.entries
    end

    test "supports a blog queryable", %{blog: blog} do
      query = from(b in Blog, where: b.name == ^blog.name)
      assert page = Blog.list(query: query)
      assert page.metadata.total_count == 1

      assert [blog] == page.entries

      query = from(b in Blog, where: b.name != ^blog.name)
      assert page = Blog.list(query: query)
      assert page.metadata.total_count == 0

      assert [] == page.entries
    end

    test "supports preloads", %{post: post} do
      assert page = Blog.list(preload: [:posts])

      assert [blog] = page.entries
      assert [post] == blog.posts
    end

    test "supports pagination", %{comment1: c1, comment2: c2, comment3: c3} do
      assert page = Comment.list(limit: 2)
      assert page.metadata.total_count == 3
      assert cursor = page.metadata.after
      assert [c1, c2] == page.entries

      assert page = Comment.list(limit: 2, after: cursor)
      assert page.metadata.total_count == 3
      refute page.metadata.after
      assert [c3] == page.entries
    end
  end
end
