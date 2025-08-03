defmodule Sleeky.Feature.UpdateActionTest do
  use Sleeky.DataCase

  alias Blogs.Publishing

  setup [:comments, :current_user]

  describe "update action" do
    test "updates attributes", %{blog: blog} = context do
      attrs = %{published: false}
      ctx = author(context).params

      assert {:ok, updated_blog} = Publishing.update_blog(blog, attrs, ctx)
      refute updated_blog.published
    end

    test "refuses access", %{blog: blog} = context do
      attrs = %{published: false}
      ctx = other_user(context).params

      assert {:error, :forbidden} = Publishing.update_blog(blog, attrs, ctx)
    end
  end
end
