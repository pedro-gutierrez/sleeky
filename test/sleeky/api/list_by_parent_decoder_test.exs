defmodule Sleeky.Api.ListByParentDecoderTest do
  use Sleeky.DataCase

  alias Blogs.Publishing.Blog

  setup [:comments]

  describe "list by parent json api decoder" do
    test "decodes parent and includes params", context do
      params = %{"id" => context.author.id, "include" => "author"}

      assert {:ok, data} = Blog.ApiListByAuthorDecoder.decode(params)
      assert data.author == context.author
      assert data.preload == [:author]
    end

    test "decodes queries attributes", context do
      params = %{"id" => context.author.id, "query" => "name:elixir,published:true"}

      assert {:ok, data} = Blog.ApiListByAuthorDecoder.decode(params)
      assert data.query.name == "elixir"
      assert data.query.published == true

      params = %{"id" => context.author.id, "query" => "name:elixir,published:false"}

      assert {:ok, data} = Blog.ApiListByAuthorDecoder.decode(params)
      assert data.query.name == "elixir"
      assert data.query.published == false

      params = %{"id" => context.author.id, "query" => "published:false"}

      assert {:ok, data} = Blog.ApiListByAuthorDecoder.decode(params)
      assert data.query.published == false
    end

    test "detects missing parent" do
      params = %{"include" => "author"}

      assert {:error, error} = Blog.ApiListByAuthorDecoder.decode(params)
      assert error["id"] == ["is required"]
    end

    test "detects unknown parents" do
      params = %{"include" => "author", "id" => Ecto.UUID.generate()}

      assert {:error, error} = Blog.ApiListByAuthorDecoder.decode(params)
      assert error["id"] == ["was not found"]
    end

    test "decodes before and after cursors", context do
      params = %{"before" => "a", "after" => "b", "limit" => "1", "id" => context.author.id}

      assert {:ok, data} = Blog.ApiListByAuthorDecoder.decode(params)
      assert data.limit == 1
      assert data.before == "a"
      assert data.after == "b"
    end
  end
end
