defmodule Sleeky.ValueTest do
  use ExUnit.Case
  import Sleeky.ErrorsHelper

  alias Blogs.Accounts.Values.UserId

  describe "validate/1" do
    test "validates a value" do
      params = %{"user_id" => "123"}

      assert {:ok, value} = UserId.validate(params)
      assert value.user_id == "123"
    end

    test "checks for required fields" do
      params = %{}

      assert {:error, changeset} = UserId.validate(params)
      assert errors_on(changeset) == %{user_id: ["can't be blank"]}
    end

    test "checks for fields of the wrong type" do
      params = %{"user_id" => 123}

      assert {:error, changeset} = UserId.validate(params)
      assert errors_on(changeset) == %{user_id: ["is invalid"]}
    end
  end
end
