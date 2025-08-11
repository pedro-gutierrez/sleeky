defmodule Sleeky.QueryTest do
  use Sleeky.DataCase

  alias Blogs.Accounts.Queries.{
    GetAllUsers,
    GetUserByEmail,
    GetUserIds
  }

  describe "scope/1" do
    test "returns nothing, if the context does not have the expected roles path" do
      context = %{}
      query = GetAllUsers.scope(context)
      sql = to_sql(query)

      assert sql =~ "WHERE (FALSE)"
    end

    test "returns the original query, if no roles are defined in the context" do
      context = %{current_user: %{roles: []}}
      query = GetAllUsers.scope(context)
      sql = to_sql(query)

      refute sql =~ "WHERE"
    end

    test "returns nothing if roles are found in the context, but none match any of the policies" do
      context = %{current_user: %{roles: [:foo]}}
      query = GetAllUsers.scope(context)
      sql = to_sql(query)

      assert sql =~ "WHERE (FALSE)"
    end

    test "returns the original query if role matches, but has no scope" do
      context = %{current_user: %{roles: [:user]}}
      query = GetUserByEmail.scope(context)
      sql = to_sql(query)

      refute sql =~ "WHERE"
    end

    test "applies extra filters to queries according to scopes" do
      context = %{current_user: %{roles: [:guest]}}
      query = GetAllUsers.scope(context)
      sql = to_sql(query)

      assert sql =~ "WHERE (u0.\"public\" = $1)"
      refute sql =~ "WHERE (FALSE)"
    end
  end

  describe "execute/1" do
    test "is used when queries have no params" do
      context = %{}
      assert [item] = GetUserIds.execute(context)
      assert item.user_id
    end
  end
end
