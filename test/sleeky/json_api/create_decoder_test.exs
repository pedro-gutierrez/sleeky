defmodule Sleeky.JsonApi.CreateDecoderTest do
  use Sleeky.DataCase

  alias Blogs.Publishing.Post

  setup [:comments, :post_json_api_params]

  describe "create api decoder" do
    test "decodes attributes and relations", context do
      params = context.post_json_api_params

      assert {:ok, data} = Post.JsonApiCreateDecoder.decode(params)

      assert data.id == params["id"]
      assert data.title == params["title"]
      assert data.blog == context.blog

      assert DateTime.to_iso8601(data.published_at) == params["published_at"]
    end

    test "detects ids that are not uuids", context do
      params =
        context.post_json_api_params
        |> Map.put("id", "foo")
        |> Map.put("blog", %{"id" => "bar"})

      assert {:error, errors} = Post.JsonApiCreateDecoder.decode(params)

      assert errors == %{
               "id" => ["not a valid uuid"],
               "blog.id" => ["not a valid uuid"]
             }
    end

    test "detects missing fields and invalid types", context do
      params =
        context.post_json_api_params
        |> Map.put("id", nil)
        |> Map.put("published_at", nil)
        |> Map.put("locked", "true")

      assert {:error, errors} = Post.JsonApiCreateDecoder.decode(params)

      assert errors == %{
               "locked" => ["expected boolean received binary"],
               "published_at" => ["expected string received nil"],
               "id" => ["is required"]
             }
    end

    test "detects unknown relations", context do
      params = Map.put(context.post_json_api_params, "blog", %{"id" => Ecto.UUID.generate()})

      assert {:error, errors} = Post.JsonApiCreateDecoder.decode(params)

      assert errors == %{"blog.id" => ["was not found"]}
    end
  end
end
