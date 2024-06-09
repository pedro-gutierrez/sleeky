defmodule Sleeky.JsonApi.ListDecoderTest do
  use Sleeky.DataCase

  alias Blogs.Publishing.Blog

  describe "list json api decoder" do
    test "decodes empty no params" do
      params = %{}
      assert {:ok, data} = Blog.JsonApiListDecoder.decode(params)
      assert data == params
    end

    test "decodes queries attributes" do
      params = %{"query" => "name:elixir,published:true"}

      assert {:ok, data} = Blog.JsonApiListDecoder.decode(params)
      assert data.query.name == "elixir"
      assert data.query.published == true

      params = %{"query" => "name:elixir,published:false"}

      assert {:ok, data} = Blog.JsonApiListDecoder.decode(params)
      assert data.query.name == "elixir"
      assert data.query.published == false

      params = %{"query" => "published:false"}

      assert {:ok, data} = Blog.JsonApiListDecoder.decode(params)
      assert data.query.published == false
    end

    test "transforms simple includes into ecto preloads" do
      params = %{"include" => "posts,author"}

      assert {:ok, data} = Blog.JsonApiListDecoder.decode(params)
      assert data.preload == [:posts, :author]
    end

    test "does not support complex includes into ecto preloads" do
      params = %{"include" => "posts,comments.author"}

      assert {:error, %{"include" => ["no such field comments.author"]}} =
               Blog.JsonApiListDecoder.decode(params)
    end

    test "rejects unknown includes" do
      params = %{"include" => "comment"}

      assert {:error, %{"include" => ["no such field comment"]}} =
               Blog.JsonApiListDecoder.decode(params)
    end

    test "decodes pagination params" do
      params = %{"before" => "a", "after" => "b", "limit" => "1"}

      assert {:ok, data} = Blog.JsonApiListDecoder.decode(params)
      assert data.limit == 1
      assert data.before == "a"
      assert data.after == "b"
    end

    test "decodes sorting params" do
      params = %{"sort" => "name:desc,published:asc"}

      assert {:ok, data} = Blog.JsonApiListDecoder.decode(params)
      assert data.sort == %{name: :desc, published: :asc}
    end

    test "ignores sorting on unknown fields" do
      params = %{"sort" => "body:desc"}

      assert {:ok, data} = Blog.JsonApiListDecoder.decode(params)
      assert Enum.empty?(data.sort)
    end
  end
end
