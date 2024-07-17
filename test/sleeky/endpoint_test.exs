defmodule Sleeky.EndpointTest do
  use Sleeky.DataCase

  alias Blogs.Publishing.Comment

  setup [:comments]

  describe "an endpoint" do
    test "has a health check" do
      "/healthz"
      |> get()
      |> ok!()
    end

    test "routes json api read requests", context do
      id = context.blog.id

      headers = %{
        "authorization" => "user " <> context.author.id
      }

      resp =
        "/api/publishing/blogs/#{id}"
        |> get(headers: headers)
        |> json_response!(200)

      assert %{
               "name" => "elixir blog",
               "published" => true,
               "id" => context.blog.id,
               "author" => %{"id" => context.author.id}
             } == resp
    end

    test "routes json api list requests", context do
      headers = %{
        "authorization" => "user " <> context.author.id
      }

      resp =
        "/api/publishing/blogs"
        |> get(headers: headers)
        |> json_response!(200)

      assert %{
               "limit" => 50,
               "total_count" => 1,
               "items" => [
                 %{
                   "name" => "elixir blog",
                   "published" => true,
                   "id" => context.blog.id,
                   "author" => %{"id" => context.author.id}
                 }
               ]
             } == resp
    end

    test "routes json api list children requests", context do
      headers = %{
        "authorization" => "user " <> context.author.id
      }

      resp =
        "/api/publishing/authors/#{context.author.id}/blogs?sort=name:desc"
        |> get(headers: headers)
        |> json_response!(200)

      assert %{
               "limit" => 50,
               "total_count" => 1,
               "items" => [
                 %{
                   "name" => "elixir blog",
                   "published" => true,
                   "id" => context.blog.id,
                   "author" => %{"id" => context.author.id}
                 }
               ]
             } == resp
    end

    test "routes json api list children requests with queries", context do
      headers = %{
        "authorization" => "user " <> context.author.id
      }

      resp =
        "/api/publishing/authors/#{context.author.id}/blogs?query=published:false"
        |> get(headers: headers)
        |> json_response!(200)

      assert %{
               "limit" => 50,
               "total_count" => 0,
               "items" => []
             } == resp
    end

    test "routes json api create requests", context do
      headers = %{
        "authorization" => "user " <> context.author.id
      }

      id = Ecto.UUID.generate()

      params = %{
        "id" => id,
        "name" => "some other blog",
        "published" => true,
        "author" => %{"id" => context.author.id}
      }

      resp =
        "/api/publishing/blogs"
        |> post(params, headers: headers)
        |> json_response!(201)

      assert %{
               "name" => "some other blog",
               "published" => true,
               "id" => id,
               "author" => %{"id" => context.author.id}
             } == resp
    end

    test "routes json api update requests", context do
      headers = %{
        "authorization" => "user " <> context.author.id
      }

      params = %{
        "name" => "updated blog name"
      }

      resp =
        "/api/publishing/blogs/#{context.blog.id}"
        |> patch(params, headers: headers)
        |> json_response!(200)

      assert %{
               "name" => "updated blog name",
               "published" => true,
               "id" => context.blog.id,
               "author" => %{"id" => context.author.id}
             } == resp
    end

    test "routes json api delete requests", context do
      headers = %{
        "authorization" => "user " <> context.author.id
      }

      "/api/publishing/comments/#{context.comment1.id}"
      |> delete(headers: headers)
      |> json_response!(204)

      assert {:error, :not_found} == Comment.fetch(context.comment1.id)
    end
  end
end
