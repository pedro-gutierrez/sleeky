defmodule Sleeky.Context.ReadActionTest do
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
  end

  describe "read by unique key" do
    test "returns the model", %{params: params, user: user} do
      assert {:ok, user} == Accounts.read_user_by_email(user.email, params)
    end
  end
end
