defmodule Sleeky.Api.UpdateHandlerTest do
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
      |> Blog.ApiUpdateHandler.execute([])
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
        |> Blog.ApiUpdateHandler.execute([])
        |> json_response!(200)

      published = context.blog.published
      id = context.blog.id
      author_id = context.author.id

      assert %{
               "name" => "blog name updated",
               "published" => ^published,
               "id" => ^id,
               "author" => %{"id" => ^author_id},
               "theme" => nil
             } = resp
    end
  end
end
