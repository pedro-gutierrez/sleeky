defmodule Sleeky.Context.DeleteActionTest do
  use Sleeky.DataCase

  alias Blogs.Publishing

  setup [:comments, :current_user]

  describe "delete action" do
    test "does not entities that have children", %{params: params, blog: blog} do
      assert {:error, changeset} = Publishing.delete_blog(blog, params)
      assert "has children" in errors_on(changeset).blog_id
    end

    test "deletes entities that have no children", %{
      params: params,
      blog: blog,
      post: post,
      comment1: c1,
      comment2: c2,
      comment3: c3
    } do
      assert :ok = Publishing.Comment.delete(c1)
      assert :ok = Publishing.Comment.delete(c2)
      assert :ok = Publishing.Comment.delete(c3)
      assert :ok = Publishing.Post.delete(post)

      assert :ok == Publishing.delete_blog(blog, params)
      assert {:error, :not_found} = Publishing.read_blog(blog.id, params)
    end

    test "refuses access", %{blog: blog} do
      context = %{current_user: %{roles: [:guest]}}

      assert {:error, :forbidden} = Publishing.delete_blog(blog, context)
    end
  end
end
