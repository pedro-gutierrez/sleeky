defmodule Sleeky.Context.AuthorizationTest do
  use Sleeky.DataCase

  alias Blogs.Accounts
  alias Blogs.Publishing

  setup [:user, :comment]

  describe "allow/3" do
    test "denies if the scope does not match", context do
      other_user = Map.put(context.user, :id, Ecto.UUID.generate())

      params = %{
        user: context.user,
        current_user: other_user
      }

      assert {:error, :forbidden} == Accounts.allow(:user, :edit, params)
    end

    test "matches on a specific model", context do
      context = %{
        user: context.user,
        current_user: context.user
      }

      assert :ok == Accounts.allow(:user, :edit, context)
    end

    test "matches on a generic model", context do
      context = %{
        blog: context.blog,
        current_user: context.user
      }

      assert :ok == Publishing.allow(:blog, :edit, context)
    end

    test "resolves ancestors lazily", context do
      context = %{
        post: context.post,
        current_user: context.user
      }

      assert :ok == Publishing.allow(:post, :edit, context)
    end

    test "resolves complex scopes", context do
      context = %{
        post: context.post,
        current_user: context.user
      }

      assert :ok == Publishing.allow(:comment, :create, context)
    end

    test "resolves very complex scopes", context do
      context = %{
        post: context.post,
        current_user: context.user
      }

      assert :ok == Publishing.allow(:comment, :edit, context)
    end
  end

  describe "scope/4" do
    test "does basic filtering", context do
      params = %{
        current_user: context.user
      }

      q =
        Accounts.User.query()
        |> Accounts.scope(:user, :list, params)

      {sql, params} = Ecto.Adapters.SQL.to_sql(:all, Blogs.Repo, q)
      assert sql =~ "WHERE (u0.\"public\" = $1)"
      assert params == [true]
    end

    test "applies multiple filters", context do
      params = %{
        current_user: context.user
      }

      q =
        Publishing.Post.query()
        |> Publishing.scope(:post, :list, params)

      {sql, params} = Ecto.Adapters.SQL.to_sql(:all, Blogs.Repo, q)
      assert sql =~ "WHERE ((p0.\"published_at\" IS NULL) AND (p0.\"locked\" = $1))"
      assert params == [false]
    end
  end
end
