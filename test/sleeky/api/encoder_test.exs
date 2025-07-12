defmodule Sleeky.Api.EncoderTest do
  use Sleeky.DataCase

  alias Sleeky.Api.Encoder
  alias Blogs.Repo

  setup [:comments, :post_api_params]

  describe "json api model encoder" do
    test "renders single models", context do
      post_id = context.post.id
      published_at = context.post.published_at
      blog_id = context.blog.id
      author_id = context.author.id

      assert %{
               published_at: ^published_at,
               title: "first post",
               deleted: false,
               locked: false,
               published: true,
               id: ^post_id,
               blog: %{
                 id: ^blog_id
               },
               author: %{
                 id: ^author_id
               }
             } = Encoder.encode(context.post)
    end

    test "renders full relations if they are loaded", context do
      post = Repo.preload(context.post, [:blog])

      post_id = context.post.id
      published_at = context.post.published_at
      blog_id = context.blog.id
      author_id = context.author.id

      assert %{
               published_at: ^published_at,
               title: "first post",
               deleted: false,
               locked: false,
               published: true,
               id: ^post_id,
               blog: %{
                 name: "elixir blog",
                 published: true,
                 id: ^blog_id,
                 author: %{id: ^author_id},
                 theme: nil
               },
               author: %{
                 id: ^author_id
               }
             } = Encoder.encode(post)
    end
  end
end
