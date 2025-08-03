defmodule Sleeky.Feature.TransactionTest do
  use Sleeky.DataCase

  alias Blogs.Accounts

  describe "transaction/1" do
    test "returns ok if everything goes well" do
      Accounts.transaction(fn ->
        with {:ok, _} <- Accounts.create_user(email: "foo@bar.com", external_id: uuid()) do
          Accounts.create_user(email: "bar@baz.com", external_id: uuid())
        end
      end)

      assert {:ok, _} = Accounts.read_user_by_email("foo@bar.com")
      assert {:ok, _} = Accounts.read_user_by_email("bar@baz.com")
    end

    test "rollbacks if something whent wrong" do
      attrs = %{email: "foo@bar.com", external_id: uuid()}

      assert {:error, reason} =
               Accounts.transaction(fn ->
                 with {:ok, _} <- Accounts.create_user(attrs) do
                   Accounts.create_user(attrs)
                 end
               end)

      assert errors_on(reason) == %{email: ["has already been taken"]}
    end
  end
end
