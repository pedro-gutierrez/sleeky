defmodule Sleeky.JsonApi.ListByParentHandlerTest do
  use Sleeky.DataCase

  alias Blogs.Publishing.Blog

  setup [:comments]

  describe "list by parent handler" do
    test "returns items", context do
      params = %{"id" => context.author.id}

      user = %{id: context.author.id, roles: [:user]}

      resp =
        params
        |> test_conn()
        |> assign(:current_user, user)
        |> Blog.JsonApiListByAuthorHandler.execute([])
        |> json_response!(200)

      assert %{
               "limit" => 50,
               "total_count" => 1,
               "items" => [
                 %{
                   "author" => %{"id" => context.author.id},
                   "id" => context.blog.id,
                   "name" => "elixir blog",
                   "published" => true
                 }
               ]
             } == resp
    end

    test "returns a 404 if the parent is not found", context do
      params = %{"id" => Ecto.UUID.generate()}

      user = %{id: context.author.id, roles: [:user]}

      params
      |> test_conn()
      |> assign(:current_user, user)
      |> Blog.JsonApiListByAuthorHandler.execute([])
      |> json_response!(404)
    end
  end
end
