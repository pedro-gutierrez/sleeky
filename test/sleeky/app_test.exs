defmodule Sleeky.AppTest do
  use ExUnit.Case

  alias Blogs.App

  describe "roles_from_context/1" do
    test "returns the roles from the context" do
      roles = [:admin]
      context = %{current_user: %{roles: roles}}

      assert {:ok, roles} == App.roles_from_context(context)
    end

    test "returns an error if the path to the roles is not found in the context" do
      context = %{}

      assert {:error, :no_such_roles_path} == App.roles_from_context(context)
    end
  end
end
