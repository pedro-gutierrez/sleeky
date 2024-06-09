defmodule Sleeky.Context.ReadActionTest do
  use Sleeky.DataCase

  alias Blogs.Publishing

  setup [:comments, :current_user]

  describe "read action" do
    test "returns models", %{params: params, blog: blog} do
      assert {:ok, _blog} = Publishing.read_blog(blog.id, params)
    end

    test "refuses access", %{blog: blog} = context do
      params = guest(context).params

      assert {:error, :forbidden} = Publishing.read_blog(blog.id, params)
    end
  end
end
