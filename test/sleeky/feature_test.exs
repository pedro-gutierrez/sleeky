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

  describe "query functions" do
    test "returns nothing, if no roles are present in the context" do
      {:ok, _} =
        Accounts.User.create(
          id: uuid(),
          email: "foo@bar",
          public: true,
          external_id: uuid()
        )

      assert [] == Accounts.get_all_users()
    end

    test "applies scopes" do
      {:ok, foo} =
        Accounts.User.create(
          id: uuid(),
          email: "foo@bar",
          public: true,
          external_id: uuid()
        )

      {:ok, _} =
        Accounts.User.create(
          id: uuid(),
          email: "bar@bar",
          public: false,
          external_id: uuid()
        )

      context = %{current_user: %{roles: [:guest]}}
      assert [^foo] = Accounts.get_all_users(context)
    end

    test "return validation errors on parameters" do
      params = %{}
      assert {:error, errors} = Accounts.get_user_by_email(params)

      assert errors_on(errors) == %{user_email: ["can't be blank"]}
    end

    test "can returns a single item" do
      {:ok, foo} =
        Accounts.User.create(
          id: uuid(),
          email: "foo@bar",
          public: true,
          external_id: uuid()
        )

      {:ok, _} =
        Accounts.User.create(
          id: uuid(),
          email: "bar@bar",
          public: false,
          external_id: uuid()
        )

      params = %{"user_email" => foo.email}
      context = %{current_user: %{roles: [:user]}}

      assert {:ok, ^foo} = Accounts.get_user_by_email(params, context)
    end

    test "returns an error if the item is not found" do
      {:ok, _} =
        Accounts.User.create(
          id: uuid(),
          email: "foo@bar",
          public: true,
          external_id: uuid()
        )

      params = %{"user_email" => "bar@bar"}
      context = %{current_user: %{roles: [:user]}}

      assert {:error, :not_found} = Accounts.get_user_by_email(params, context)
    end
  end
end
