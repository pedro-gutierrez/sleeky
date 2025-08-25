defmodule Sleeky.FeatureTest do
  use Sleeky.DataCase

  alias Blogs.Accounts
  alias Blogs.Accounts.Events.UserRegistered
  alias Blogs.Accounts.Onboarding
  alias Blogs.Accounts.User
  alias Blogs.Accounts.Values.UserId
  alias Blogs.Accounts.Values.UserEmail

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
      params = [email: ["foo@bar", "bar@bar"]]

      assert users = Accounts.get_users_by_emails(params, context)
      assert length(users) == 2
    end
  end

  describe "map/3" do
    test "maps input to output value using mappings" do
      input = %{id: "1"}
      assert {:ok, user_id} = Accounts.map(Map, UserId, input)
      assert user_id.__struct__ == UserId
      assert user_id.user_id == "1"
    end

    test "maps multiple items when using mappings" do
      inputs = [%{id: "1"}, %{id: "2"}]
      assert {:ok, [user_id1, user_id2]} = Accounts.map(Map, UserId, inputs)
      assert user_id1.__struct__ == UserId
      assert user_id1.user_id == "1"
      assert user_id2.__struct__ == UserId
      assert user_id2.user_id == "2"
    end

    test "validates the output when using mappings" do
      input = %{id: 1}
      assert {:error, reason} = Accounts.map(Map, UserId, input)
      assert errors_on(reason) == %{user_id: ["is invalid"]}
    end

    test "maps input to output value also when not using mappings" do
      input = %{email: "foo@bar"}
      assert {:ok, user_email} = Accounts.map(Map, UserEmail, input)
      assert user_email.__struct__ == UserEmail
      assert user_email.email == "foo@bar"
    end

    test "maps multiple inputs when not using mappings" do
      inputs = [%{email: "foo@bar"}, %{email: "bar@bar"}]
      assert {:ok, [user_email1, user_email2]} = Accounts.map(Map, UserEmail, inputs)
      assert user_email1.__struct__ == UserEmail
      assert user_email1.email == "foo@bar"
      assert user_email2.__struct__ == UserEmail
      assert user_email2.email == "bar@bar"
    end

    test "validate the output even if a mapping is not defined" do
      input = %{email: 1}
      assert {:error, reason} = Accounts.map(Map, UserEmail, input)
      assert errors_on(reason) == %{email: ["is invalid"]}
    end
  end
end
