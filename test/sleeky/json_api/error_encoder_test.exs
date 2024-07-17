defmodule Sleeky.JsonApi.ErrorEncoderTest do
  use Sleeky.DataCase

  alias Sleeky.JsonApi.ErrorEncoder
  alias Blogs.Publishing.Post

  describe "json api error encoder" do
    test "encodes validation errors" do
      errors = %{
        "field" => ["error one", "error two"]
      }

      assert {:error, errors} == ErrorEncoder.encode_errors(errors)
    end

    test "encodes simple errors" do
      assert {:error, error} = ErrorEncoder.encode_errors(:forbidden)

      assert %{reason: :forbidden} == error
    end

    test "encodes ecto changeset errors" do
      errors = %Post{} |> Post.insert_changeset(%{})

      assert {:error, errors} = ErrorEncoder.encode_errors(errors)

      assert errors
             |> Map.values()
             |> Enum.all?(&(&1 == ["can't be blank"]))
    end
  end
end
