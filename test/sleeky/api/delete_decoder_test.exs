defmodule Sleeky.Api.DeleteDecoderTest do
  use Sleeky.DataCase

  alias Blogs.Publishing.Post

  describe "delete api decoder" do
    test "decodes the model id" do
      id = Ecto.UUID.generate()
      params = %{"id" => id}

      assert {:ok, data} = Post.ApiDeleteDecoder.decode(params)
      assert data.id == id
    end
  end
end
