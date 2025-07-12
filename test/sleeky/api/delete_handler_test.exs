defmodule Sleeky.Api.DeleteHandlerTest do
  use Sleeky.DataCase

  alias Blogs.Publishing.{Blog, Comment}

  setup [:comments]

  describe "delete handler" do
    test "does authorization", context do
      params = %{
        "id" => context.blog.id
      }

      guest = %{roles: [:guest]}

      params
      |> test_conn()
      |> assign(:current_user, guest)
      |> Blog.ApiDeleteHandler.execute([])
      |> json_response!(403)
    end

    test "returns not found codes", context do
      params = %{
        "id" => Ecto.UUID.generate()
      }

      user = %{roles: [:user], id: context.author.id}

      params
      |> test_conn()
      |> assign(:current_user, user)
      |> Blog.ApiDeleteHandler.execute([])
      |> json_response!(404)
    end

    test "does not delete models with children", context do
      params = %{
        "id" => context.blog.id
      }

      user = %{roles: [:user], id: context.author.id}

      resp =
        params
        |> test_conn()
        |> assign(:current_user, user)
        |> Blog.ApiDeleteHandler.execute([])
        |> json_response!(412)

      assert %{
               "blog_id" => ["has children"]
             } == resp
    end

    test "deletes models", context do
      params = %{
        "id" => context.comment1.id
      }

      user = %{roles: [:user], id: context.author.id}

      params
      |> test_conn()
      |> assign(:current_user, user)
      |> Comment.ApiDeleteHandler.execute([])
      |> json_response!(204)

      assert {:error, :not_found} = Blog.fetch(context.comment1.id)
    end
  end
end
