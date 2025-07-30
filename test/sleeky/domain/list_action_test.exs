defmodule Sleeky.Domain.ListActionTest do
  use Sleeky.DataCase

  alias Blogs.Publishing

  setup [:comments, :current_user]

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

    test "skips auth when no roles are provided", %{blog: blog} do
      assert page = Publishing.list_blogs()
      assert [blog] == page.entries
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

    test "supports query filtering", context do
      params = Map.put(context.params, :query, %{body: "1"})
      assert page = Publishing.list_comments(params)
      assert [c] = page.entries
      assert c == context.comment1
    end

    test "supports sorting", context do
      params = Map.put(context.params, :sort, inserted_at: :asc)
      assert page = Publishing.list_comments(params)
      assert [c1, c2, c3] = page.entries

      params = Map.put(context.params, :sort, inserted_at: :desc)
      assert page = Publishing.list_comments(params)
      assert [^c3, ^c2, ^c1] = page.entries
    end
  end
end
