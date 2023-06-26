defmodule Blog.UserTest do
  use Blog.Case

  describe "POST /api/users" do
    test "creates a new user" do
      assert %{"id" => _, "email" => _} =
               post_json("/api/users", %{email: "alice@example.com"})
               |> json_response(201)
    end

    test "does not create the same user twice" do
      post_json("/api/users", %{email: "alice@example.com"})
      |> json_response(201)

      post_json("/api/users", %{email: "alice@example.com"})
      |> json_response(409)

      assert [%{"id" => _}] =
               get("/api/users")
               |> json_response()
    end
  end
end
