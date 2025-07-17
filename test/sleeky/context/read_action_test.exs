defmodule Sleeky.Domain.ReadActionTest do
  use Sleeky.DataCase

  alias Blogs.{Accounts, Publishing}

  setup [:comments, :current_user]

  describe "read by id action" do
    test "returns models", %{params: params, blog: blog} do
      assert {:ok, _blog} = Publishing.read_blog(blog.id, params)
    end

    test "refuses access", %{blog: blog} = context do
      params = guest(context).params

      assert {:error, :forbidden} = Publishing.read_blog(blog.id, params)
    end

    test "returns model with preloaded relations", %{blog: blog, author: author} do
      assert {:ok, blog} = Publishing.read_blog(blog.id, %{preload: [:author]})
      assert blog.author == author
    end
  end

  describe "read by unique key" do
    test "returns the model", %{params: params, user: user} do
      assert {:ok, user} == Accounts.read_user_by_email(user.email, params)
    end

    test "returns an error whent not found", %{params: params} do
      assert {:error, :not_found} == Accounts.read_user_by_email("unknown@email", params)
    end
  end
end
