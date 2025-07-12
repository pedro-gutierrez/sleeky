defmodule Sleeky.Api.ListHandlerTest do
  use Sleeky.DataCase

  alias Blogs.Publishing.{Blog, Comment}

  setup [:comments]

  describe "list handler" do
    test "returns models", context do
      params = %{}

      user = %{id: context.author.id, roles: [:user]}

      resp =
        params
        |> test_conn()
        |> assign(:current_user, user)
        |> Blog.ApiListHandler.execute([])
        |> json_response!(200)

      author_id = context.author.id
      blog_id = context.blog.id

      assert %{
               "limit" => 50,
               "total_count" => 1,
               "items" => [
                 %{
                   "author" => %{"id" => ^author_id},
                   "id" => ^blog_id,
                   "name" => "elixir blog",
                   "published" => true,
                   "theme" => nil
                 }
               ]
             } = resp
    end

    test "returns included parents", context do
      params = %{"include" => "author"}

      user = %{id: context.author.id, roles: [:user]}

      resp =
        params
        |> test_conn()
        |> assign(:current_user, user)
        |> Blog.ApiListHandler.execute([])
        |> json_response!(200)

      author_id = context.author.id
      blog_id = context.blog.id

      assert %{
               "limit" => 50,
               "total_count" => 1,
               "items" => [
                 %{
                   "author" => %{"id" => ^author_id, "name" => "foo"},
                   "id" => ^blog_id,
                   "name" => "elixir blog",
                   "published" => true
                 }
               ]
             } = resp
    end

    test "supports query filters", context do
      params = %{"include" => "author", "query" => "name:finance"}

      user = %{id: context.author.id, roles: [:user]}

      resp =
        params
        |> test_conn()
        |> assign(:current_user, user)
        |> Blog.ApiListHandler.execute([])
        |> json_response!(200)

      assert %{
               "limit" => 50,
               "total_count" => 0,
               "items" => []
             } == resp
    end

    test "supports pagination" do
      params = %{"limit" => "1"}
      user = %{roles: [:user]}

      resp =
        params
        |> test_conn()
        |> assign(:current_user, user)
        |> Comment.ApiListHandler.execute([])
        |> json_response!(200)

      after_cursor = resp["after"]
      assert resp["total_count"] > 1
      assert [c1] = resp["items"]

      assert after_cursor

      params = %{"limit" => "1", "after" => after_cursor}

      resp =
        params
        |> test_conn()
        |> assign(:current_user, user)
        |> Comment.ApiListHandler.execute([])
        |> json_response!(200)

      before_cursor = resp["before"]
      assert [c2] = resp["items"]
      refute c1 == c2

      params = %{"limit" => "1", "before" => before_cursor}

      resp =
        params
        |> test_conn()
        |> assign(:current_user, user)
        |> Comment.ApiListHandler.execute([])
        |> json_response!(200)

      assert [c3] = resp["items"]

      assert c1 == c3
    end

    test "supports sorting" do
      params = %{"sort" => "body:asc"}
      user = %{roles: [:user]}

      resp =
        params
        |> test_conn()
        |> assign(:current_user, user)
        |> Comment.ApiListHandler.execute([])
        |> json_response!(200)

      bodies = Enum.map(resp["items"], & &1["body"])
      assert bodies == Enum.sort(bodies)

      params = %{"sort" => "body:desc"}

      resp =
        params
        |> test_conn()
        |> assign(:current_user, user)
        |> Comment.ApiListHandler.execute([])
        |> json_response!(200)

      bodies2 = Enum.map(resp["items"], & &1["body"])
      assert Enum.reverse(bodies2) == bodies
    end

    test "ignores sorting on unknown fields" do
      params = %{"sort" => "name:asc"}
      user = %{roles: [:user]}

      params
      |> test_conn()
      |> assign(:current_user, user)
      |> Comment.ApiListHandler.execute([])
      |> json_response!(200)
    end
  end
end
