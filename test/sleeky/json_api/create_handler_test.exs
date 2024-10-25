defmodule Sleeky.JsonApi.CreateHandlerTest do
  use Sleeky.DataCase

  alias Blogs.Publishing.Author
  alias Blogs.Publishing.Blog

  setup [:comments]

  describe "create handler" do
    test "validates params" do
      params = %{
        "name" => "john"
      }

      errors =
        :post
        |> conn("/", params)
        |> Author.JsonApiCreateHandler.execute([])
        |> json_response!(400)

      assert %{
               "id" => ["is required"]
             } == errors
    end

    test "denies access if no role matches" do
      params = %{
        "id" => Ecto.UUID.generate(),
        "name" => "john"
      }

      errors =
        :post
        |> conn("/", params)
        |> assign(:current_user, %{roles: [:other]})
        |> Author.JsonApiCreateHandler.execute([])
        |> json_response!(403)

      assert %{
               "reason" => "forbidden"
             } == errors
    end

    test "allows access if no roles are defined" do
      params = %{
        "id" => Ecto.UUID.generate(),
        "name" => "john"
      }

      :post
      |> conn("/", params)
      |> assign(:current_user, %{roles: []})
      |> Author.JsonApiCreateHandler.execute([])
      |> json_response!(201)
    end

    test "creates top level models" do
      id = Ecto.UUID.generate()

      params = %{
        "id" => id,
        "name" => "john"
      }

      guest = %{roles: [:guest]}

      resp =
        :post
        |> conn("/", params)
        |> assign(:current_user, guest)
        |> Author.JsonApiCreateHandler.execute([])
        |> json_response!(201)

      assert %{
               "name" => "john",
               "id" => id
             } == resp
    end

    test "creates child models", context do
      id = Ecto.UUID.generate()

      params = %{
        "id" => id,
        "name" => "new blog",
        "published" => true,
        "author" => %{"id" => context.author.id}
      }

      guest = %{roles: [:user], id: context.author.id}

      resp =
        :post
        |> conn("/", params)
        |> assign(:current_user, guest)
        |> Blog.JsonApiCreateHandler.execute([])
        |> json_response!(201)

      author_id = context.author.id

      assert %{
               "name" => "new blog",
               "published" => true,
               "id" => ^id,
               "author" => %{"id" => ^author_id}
             } = resp
    end

    test "detects conflicts", context do
      params = %{
        "id" => context.author.id,
        "name" => "john"
      }

      guest = %{roles: [:guest]}

      :post
      |> conn("/", params)
      |> assign(:current_user, guest)
      |> Author.JsonApiCreateHandler.execute([])
      |> json_response!(409)
    end
  end
end
