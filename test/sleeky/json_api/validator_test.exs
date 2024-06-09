defmodule Sleeky.JsonApi.ValidatorTest do
  use Sleeky.DataCase

  setup [:comments, :post_json_api_params]

  describe "mutation api validator" do
    test "validates attributes and relations", context do
      params = context.post_json_api_params

      assert {:ok, data} = Blogs.Publishing.Post.JsonApiValidator.validate(params)

      assert data.id == params["data"]["id"]
      assert data.title == params["data"]["attributes"]["title"]
      assert data.blog == context.blog

      assert DateTime.to_iso8601(data.published_at) ==
               params["data"]["attributes"]["published_at"]
    end

    test "detects ids that are not uuids", context do
      params =
        context.post_json_api_params
        |> put_in(["data", "id"], "foo")
        |> put_in(["data", "relationships", "blog", "data", "id"], "bar")

      assert {:error, errors} = Blogs.Publishing.Post.JsonApiValidator.validate(params)

      assert errors == %{
               "data.relationships.blog.data.id" => [{:error, "not a valid uuid"}],
               "data.id" => ["not a valid uuid"]
             }
    end

    test "detects missing fields and invalid types", context do
      params =
        context.post_json_api_params
        |> put_in(["data", "id"], nil)
        |> put_in(["data", "relationships"], %{})
        |> put_in(["data", "attributes", "published_at"], nil)
        |> put_in(["data", "attributes", "locked"], "true")

      assert {:error, errors} = Blogs.Publishing.Post.JsonApiValidator.validate(params)

      assert errors == %{
               "data.attributes.locked" => ["expected boolean received binary"],
               "data.attributes.published_at" => ["expected string received nil"],
               "data.relationships" => ["is required"],
               "data.id" => ["is required"]
             }
    end

    test "detects unknown relations", context do
      params =
        put_in(
          context.post_json_api_params,
          ["data", "relationships", "blog", "data", "id"],
          Ecto.UUID.generate()
        )

      assert {:error, errors} = Blogs.Publishing.Post.JsonApiValidator.validate(params)

      assert errors == %{"data.relationships.blog.data.id" => ["was not found"]}
    end
  end
end
