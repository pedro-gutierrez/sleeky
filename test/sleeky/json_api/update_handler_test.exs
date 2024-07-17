defmodule Sleeky.JsonApi.UpdateHandlerTest do
  use Sleeky.DataCase

  alias Blogs.Publishing.Blog

  setup [:comments]

  describe "update handler" do
    test "does authorization", context do
      params = %{
        "id" => context.blog.id,
        "name" => "blog name updated"
      }

      guest = %{roles: [:guest]}

      :post
      |> conn("/", params)
      |> assign(:current_user, guest)
      |> Blog.JsonApiUpdateHandler.execute([])
      |> json_response!(403)
    end

    test "updates attributes", context do
      params = %{
        "id" => context.blog.id,
        "name" => "blog name updated"
      }

      author = %{roles: [:user], id: context.author.id}

      resp =
        :post
        |> conn("/", params)
        |> assign(:current_user, author)
        |> Blog.JsonApiUpdateHandler.execute([])
        |> json_response!(200)

      assert %{
               "name" => "blog name updated",
               "published" => context.blog.published,
               "id" => context.blog.id,
               "author" => %{"id" => context.author.id}
             } == resp
    end
  end
end
