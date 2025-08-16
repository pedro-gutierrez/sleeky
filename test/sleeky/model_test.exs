defmodule Sleeky.ModelTest do
  use Sleeky.DataCase

  alias Blogs.Accounts
  alias Blogs.Accounts.User
  alias Blogs.Accounts.Onboarding

  describe "describe field/1" do
    test "finds built-in fields" do
      assert {:ok, field} = User.field(:inserted_at)
      assert field.name == :inserted_at
    end
  end

  describe "create/1" do
    test "detects conflicts" do
      attrs = [
        id: Ecto.UUID.generate(),
        email: "foo@bar",
        public: true,
        external_id: Ecto.UUID.generate()
      ]

      assert {:ok, _onboarding} = User.create(attrs)

      assert {:error, errors} =
               attrs
               |> Keyword.put(:id, Ecto.UUID.generate())
               |> User.create()

      assert errors_on(errors) == %{email: ["has already been taken"]}
    end

    test "merges records on conflict when the strategy is set" do
      attrs = [
        user_id: Ecto.UUID.generate(),
        steps_pending: 1,
        id: Ecto.UUID.generate()
      ]

      assert {:ok, _onboarding} = Onboarding.create(attrs)

      assert {:ok, onboarding} =
               attrs
               |> Keyword.put(:id, Ecto.UUID.generate())
               |> Keyword.put(:steps_pending, 0)
               |> Onboarding.create()

      assert onboarding.user_id == attrs[:user_id]
      assert onboarding.steps_pending == 0
      assert onboarding.id == attrs[:id]
    end
  end

  describe "create_many/1" do
    test "merges records on conflict when the strategy is set" do
      user_id = uuid()

      o1 = [
        id: uuid(),
        user_id: user_id,
        steps_pending: 2
      ]

      o2 = [
        id: uuid(),
        user_id: user_id,
        steps_pending: 3
      ]

      assert :ok = Onboarding.create_many([o1])
      assert :ok = Onboarding.create_many([o2])

      assert [onboarding] = Accounts.get_onboardings()
      assert onboarding.steps_pending == 3
    end
  end
end
