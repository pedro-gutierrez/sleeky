defmodule Sleeky.FeatureTest do
  use Sleeky.DataCase

  alias Blogs.Accounts

  describe "command functions" do
    test "invoke the handler if the command is allowed" do
      params = %{email: "test@example.com", external_id: uuid(), id: uuid()}
      context = %{current_user: %{roles: [:guest]}}

      assert {:ok, _user} = Accounts.register_user(params, context)
    end

    test "do not call the handler if the command is not allowed" do
      params = %{email: "test@example.com", external_id: uuid(), id: uuid()}
      context = %{current_user: %{roles: [:admin]}}

      assert {:error, :unauthorized} == Accounts.register_user(params, context)
      assert 0 == Blogs.Repo.aggregate(Accounts.User, :count)
    end

    test "rollbacks the transaction if the handler fails" do
      params = %{email: "foo@bar.com", external_id: uuid(), id: uuid()}
      context = %{current_user: %{roles: [:guest]}}

      assert {:error, :invalid_email} = Accounts.register_user(params, context)
      assert 0 == Blogs.Repo.aggregate(Accounts.User, :count)
    end
  end
end
