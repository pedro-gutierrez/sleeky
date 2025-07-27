defmodule Sleeky.Domain.AuthorizationTest do
  use Sleeky.DataCase

  alias Blogs.Accounts
  alias Blogs.Publishing

  setup [:comments, :current_user]

  describe "allow/3" do
    test "denies if the scope does not match", context do
      params =
        context
        |> other_user()
        |> Map.fetch!(:params)
        |> Map.put(:user, context.user)

      assert {:error, :forbidden} == Accounts.allow(:user, :update, params)
    end

    test "matches on a specific model", %{user: user, params: params} do
      params = Map.put(params, :user, user)

      assert :ok == Accounts.allow(:user, :update, params)
    end

    test "matches on a generic model", %{post: blog, params: params} do
      params = Map.put(params, :blog, blog)

      assert :ok == Publishing.allow(:blog, :update, params)
    end

    test "resolves ancestors lazily", %{post: post, params: params} do
      params = Map.put(params, :post, post)

      assert :ok == Publishing.allow(:post, :update, params)
    end

    test "resolves complex scopes", %{post: post, params: params} do
      params = Map.put(params, :post, post)

      assert :ok == Publishing.allow(:comment, :create, params)
    end

    test "resolves very complex scopes", %{post: post, params: params} do
      params = Map.put(params, :post, post)

      assert :ok == Publishing.allow(:comment, :update, params)
    end
  end

  describe "scope/4" do
    test "does basic filtering", %{params: params} do
      q =
        Accounts.User.query()
        |> Accounts.scope(:user, :list, params)

      {sql, params} = Ecto.Adapters.SQL.to_sql(:all, Blogs.Repo, q)
      assert sql =~ "WHERE (u0.\"public\" = $1)"
      assert params == [true]
    end

    test "filters on model ids", %{user: user, params: params} do
      q =
        Publishing.Blog.query()
        |> Publishing.scope(:blog, :list, params)

      {sql, params} = Ecto.Adapters.SQL.to_sql(:all, Blogs.Repo, q)

      assert sql =~ "WHERE (b0.\"author_id\" = $1)"
      assert params == [Ecto.UUID.dump!(user.id)]
    end

    test "applies multiple filters", %{params: params} do
      q =
        Publishing.Post.query()
        |> Publishing.scope(:post, :list, params)

      {sql, params} = Ecto.Adapters.SQL.to_sql(:all, Blogs.Repo, q)
      assert sql =~ "WHERE (NOT (p0.\"published_at\" IS NULL) AND (p0.\"locked\" = $1))"
      assert params == [false]
    end
  end
end
