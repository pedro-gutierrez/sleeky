defmodule Sleeky.FeatureTest do
  use Sleeky.DataCase

  alias Blogs.Accounts
  alias Blogs.Accounts.Events.UserRegistered
  alias Blogs.Accounts.Onboarding
  alias Blogs.Accounts.User
  alias Blogs.Accounts.Values.UserId

  describe "command functions" do
    test "invoke the handler if the command is allowed" do
      params = %{email: "test@example.com", external_id: uuid(), id: uuid()}
      context = %{current_user: %{roles: [:guest]}}

      assert {:ok, _user} = Accounts.register_user(params, context)
      refute_event_published(UserRegistered)
    end

    test "publishes events if explicit conditions are matched" do
      params = %{email: "test@gmail.com", external_id: uuid(), id: uuid()}
      context = %{current_user: %{roles: [:guest]}}

      assert {:ok, _user} = Accounts.register_user(params, context)
      assert_event_published(UserRegistered)
    end

    test "does not publish events if explicit conditions are matched" do
      params = %{email: "fake@gmail.com", external_id: uuid(), id: uuid()}
      context = %{current_user: %{roles: [:guest]}}

      assert {:ok, _user} = Accounts.register_user(params, context)
      refute_event_published(UserRegistered)
    end

    test "accepts value structs as parameters" do
      params = %User{email: "test@example.com", external_id: uuid(), id: uuid()}
      context = %{current_user: %{roles: [:guest]}}

      assert {:ok, _user} = Accounts.register_user(params, context)
      refute_event_published(UserRegistered)
    end

    test "accepts keyword lists as parameters" do
      params = [email: "test@example.com", external_id: uuid(), id: uuid()]
      context = %{current_user: %{roles: [:guest]}}

      assert {:ok, _user} = Accounts.register_user(params, context)
      refute_event_published(UserRegistered)
    end

    test "do not call the handler if the command is not allowed" do
      params = %{email: "test@example.com", external_id: uuid(), id: uuid()}
      context = %{current_user: %{roles: [:admin]}}

      assert {:error, :unauthorized} == Accounts.register_user(params, context)
      assert 0 == Blogs.Repo.aggregate(Accounts.User, :count)

      refute_event_published(UserRegistered)
    end

    test "rollbacks the transaction if the handler fails" do
      params = %{email: "foo@bar.com", external_id: uuid(), id: uuid()}
      context = %{current_user: %{roles: [:guest]}}

      assert {:error, :invalid_email} = Accounts.register_user(params, context)
      assert 0 == Blogs.Repo.aggregate(Accounts.User, :count)

      refute_event_published(UserRegistered)
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

      assert [] == Accounts.get_users()
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
      assert [^foo] = Accounts.get_users(context)
    end

    test "return validation errors on parameters" do
      params = %{}
      assert {:error, errors} = Accounts.get_user_by_email(params)

      assert errors_on(errors) == %{email: ["can't be blank"]}
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

      params = %{"email" => foo.email}
      context = %{current_user: %{roles: [:user]}}

      assert {:ok, ^foo} = Accounts.get_user_by_email(params, context)
    end

    test "returns an error if the item is not found" do
      params = %{"email" => "bar@bar"}
      context = %{current_user: %{roles: [:user]}}

      assert {:error, :not_found} = Accounts.get_user_by_email(params, context)
    end

    test "accept keyword lists as parameters" do
      context = %{current_user: %{roles: [:user]}}
      params = [email: "bar@bar"]

      assert {:error, :not_found} = Accounts.get_user_by_email(params, context)
    end

    test "can execute custom queries on read models" do
      assert [item] = Accounts.get_user_ids()

      assert is_struct(item)
      assert item.__struct__ == UserId
      assert item.user_id
    end

    test "sorts results" do
      assert {:ok, o1} = Onboarding.create(id: uuid(), user_id: uuid(), steps_pending: 1)
      assert {:ok, o2} = Onboarding.create(id: uuid(), user_id: uuid(), steps_pending: 3)

      assert [^o2, ^o1] = Accounts.get_onboardings()
    end

    test "support lists of strings as parameters" do
      {:ok, _} =
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

      context = %{current_user: %{roles: [:user]}}
      params = [emails: ["foo@bar", "bar@bar"]]

      assert users = Accounts.get_users_by_emails(params, context)
      assert length(users) == 2
    end
  end
end
