defmodule Sleeky.JsonApi.ReadHandlerTest do
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
      |> Blog.JsonApiReadHandler.execute([])
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
      |> Blog.JsonApiReadHandler.execute([])
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
        |> Blog.JsonApiReadHandler.execute([])
        |> json_response!(200)

      assert %{
               "author" => %{"id" => context.author.id},
               "id" => context.blog.id,
               "name" => "elixir blog",
               "published" => true
             } == resp
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
        |> Blog.JsonApiReadHandler.execute([])
        |> json_response!(200)

      assert %{
               "author" => %{"id" => context.author.id, "name" => "foo"},
               "id" => context.blog.id,
               "name" => "elixir blog",
               "published" => true
             } == resp
    end
  end
end
