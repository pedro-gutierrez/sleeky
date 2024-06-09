defmodule Sleeky.JsonApi.EncoderTest do
  use Sleeky.DataCase

  alias Sleeky.JsonApi.Encoder
  alias Blogs.Repo

  setup [:comments, :post_json_api_params]

  describe "json api model encoder" do
    test "renders single models", context do
      assert %{
               published_at: context.post.published_at,
               title: "first post",
               deleted: false,
               locked: false,
               published: true,
               id: context.post.id,
               blog: %{
                 id: context.blog.id
               }
             } == Encoder.encode(context.post)
    end

    test "renders full relations if they are loaded", context do
      post = Repo.preload(context.post, [:blog])

      assert %{
               published_at: context.post.published_at,
               title: "first post",
               deleted: false,
               locked: false,
               published: true,
               id: context.post.id,
               blog: %{
                 name: "elixir blog",
                 published: true,
                 id: context.blog.id,
                 author: %{id: context.author.id}
               }
             } == Encoder.encode(post)
    end
  end
end
