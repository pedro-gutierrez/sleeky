defmodule Sleeky.Api.UpdateDecoderTest do
  use Sleeky.DataCase

  alias Blogs.Publishing.Blog

  setup [:comments, :post_api_params]

  describe "update api decoder" do
    test "only validates params that are present", context do
      params = %{
        "id" => context.blog.id,
        "name" => "blog name updated"
      }

      assert {:ok,
              %{
                id: context.blog.id,
                name: "blog name updated"
              }} == Blog.ApiUpdateDecoder.decode(params)
    end

    test "validates relations", context do
      params = %{
        "id" => context.blog.id,
        "name" => "blog name updated",
        "author" => %{"id" => context.author.id}
      }

      assert {:ok,
              %{
                id: context.blog.id,
                name: "blog name updated",
                author: context.author
              }} == Blog.ApiUpdateDecoder.decode(params)
    end
  end
end
