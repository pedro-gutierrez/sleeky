defmodule Sleeky.Api.ReadHandlerTest do
  use Sleeky.DataCase

  alias Blogs.Publishing.Blog

  setup [:comments]

  describe "read handler" do
    test "does authorization", context do
      params = %{
        "id" => context.blog.id
      }

      guest = %{roles: [:guest]}

      params
      |> test_conn()
      |> assign(:current_user, guest)
      |> Blog.ApiReadHandler.execute([])
      |> json_response!(403)
    end

    test "returns not found codes" do
      params = %{
        "id" => Ecto.UUID.generate()
      }

      user = %{roles: [:user]}

      params
      |> test_conn()
      |> assign(:current_user, user)
      |> Blog.ApiReadHandler.execute([])
      |> json_response!(404)
    end

    test "returns models", context do
      params = %{
        "id" => context.blog.id
      }

      user = %{roles: [:user]}

      resp =
        params
        |> test_conn()
        |> assign(:current_user, user)
        |> Blog.ApiReadHandler.execute([])
        |> json_response!(200)

      blog_id = context.blog.id
      author_id = context.author.id

      assert %{
               "author" => %{"id" => ^author_id},
               "id" => ^blog_id,
               "name" => "elixir blog",
               "published" => true,
               "theme" => nil
             } = resp
    end

    test "returns included parents", context do
      params = %{
        "include" => "author",
        "id" => context.blog.id
      }

      user = %{id: context.author.id, roles: [:user]}

      resp =
        params
        |> test_conn()
        |> assign(:current_user, user)
        |> Blog.ApiReadHandler.execute([])
        |> json_response!(200)

      blog_id = context.blog.id
      author_id = context.author.id

      assert %{
               "author" => %{"id" => ^author_id, "name" => "foo"},
               "id" => ^blog_id,
               "name" => "elixir blog",
               "published" => true,
               "theme" => nil
             } = resp
    end
  end
end
