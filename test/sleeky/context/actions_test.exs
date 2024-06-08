defmodule Sleeky.Context.ActionsTest do
  use Sleeky.DataCase

  alias Blogs.Publishing

  setup [:user, :comments, :current_user]

  describe "create action" do
    test "requires an id", context do
      attrs = %{id: uuid(), name: "author"}
      params = guest(context).params

      assert {:ok, author} = Publishing.create_author(attrs, params)
      assert author.id == attrs.id
      assert author.name == attrs.name
    end

    test "creates children too", context do
      attrs = %{
        id: uuid(),
        name: "author",
        blogs: [
          %{id: uuid(), name: "my blog", published: true}
        ]
      }

      params = guest(context).params

      assert {:ok, author} = Publishing.create_author(attrs, params)
      assert [blog] = author.blogs
      assert blog.name == "my blog"
    end
  end

  describe "update action" do
    test "updates attributes", %{author: author, blog: blog, params: params} do
      attrs = %{published: false}

      assert {:ok, updated_blog} = Publishing.update_blog(author, blog, attrs, params)
      refute updated_blog.published
    end

    test "refuses access", %{author: author, blog: blog} = context do
      params = other_user(context).params
      attrs = %{published: false}

      assert {:error, :forbidden} = Publishing.update_blog(author, blog, attrs, params)
    end
  end

  describe "read action" do
    test "returns models", %{params: params, blog: blog} do
      assert {:ok, _blog} = Publishing.read_blog(blog.id, params)
    end

    test "refuses access", %{blog: blog} = context do
      params = guest(context).params

      assert {:error, :forbidden} = Publishing.read_blog(blog.id, params)
    end
  end

  describe "delete action" do
    test "does not models that have children", %{params: params, blog: blog} do
      assert {:error, changeset} = Publishing.delete_blog(blog, params)
      assert "has children" in errors_on(changeset).blog_id
    end

    test "deletes models that have no children", %{
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

  describe "list action" do
    test "returns items", %{blog: blog, params: params} do
      assert page = Publishing.list_blogs(params)
      assert [blog] == page.entries
    end

    test "scopes queries", %{params: params} do
      params = put_in(params, [:current_user, :id], uuid())

      assert page = Publishing.list_blogs(params)
      assert [] == page.entries
    end

    test "lists items by their parent", %{params: params, post: post} do
      assert page = Publishing.list_comments_by_post(post, params)
      assert [_c1, _c2, _c3] = page.entries
    end

    test "supports pagination", %{post: post, params: params} do
      params = Map.put(params, :limit, 1)
      assert page = Publishing.list_comments_by_post(post, params)
      assert page.metadata.after
      assert [_c1] = page.entries
    end
  end
end
