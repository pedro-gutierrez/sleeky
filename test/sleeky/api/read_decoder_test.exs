defmodule Sleeky.Api.ReadDecoderTest do
  use Sleeky.DataCase

  alias Blogs.Publishing.Post

  describe "read api decoder" do
    test "decodes the entity id and preload" do
      id = Ecto.UUID.generate()
      params = %{"id" => id, "include" => "blog"}

      assert {:ok, data} = Post.ApiReadDecoder.decode(params)
      assert data.id == id
      assert data.preload == [:blog]
    end
  end
end
