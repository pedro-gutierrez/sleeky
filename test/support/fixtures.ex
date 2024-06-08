defmodule Sleeky.Fixtures do
  @moduledoc false

  alias Blogs.Accounts
  alias Blogs.Publishing

  @doc "A convenience function to generate uuids in tests"
  def uuid, do: Ecto.UUID.generate()

  def current_user(context) do
    user = %{id: context.author.id, roles: [:user]}

    replace_current_user(context, user)
  end

  def other_user(context) do
    user = %{id: uuid(), roles: [:user]}

    replace_current_user(context, user)
  end

  def guest(context) do
    user = %{roles: [:guest]}

    replace_current_user(context, user)
  end

  defp replace_current_user(context, user) do
    params =
      context
      |> Map.get(:params, %{})
      |> Map.put(:current_user, user)

    Map.put(context, :params, params)
  end

  def user(context) do
    {:ok, user} = Accounts.User.create(id: Ecto.UUID.generate(), email: "foo@bar", public: true)
    Map.put(context, :user, user)
  end

  def comments(context) do
    {:ok, author} = Publishing.Author.create(id: context.user.id, name: "foo")

    {:ok, blog} =
      Publishing.Blog.create(
        id: uuid(),
        published: true,
        author_id: author.id,
        name: "elixir blog"
      )

    {:ok, post} =
      Publishing.Post.create(
        id: uuid(),
        blog_id: blog.id,
        published: true,
        deleted: false,
        title: "first post",
        locked: false,
        published_at: DateTime.utc_now()
      )

    {:ok, comment1} =
      Publishing.Comment.create(
        id: uuid(),
        post_id: post.id,
        author_id: author.id,
        body: "comment 1",
        published_at: DateTime.utc_now()
      )

    {:ok, comment2} =
      Publishing.Comment.create(
        id: uuid(),
        post_id: post.id,
        author_id: author.id,
        body: "comment 2",
        published_at: DateTime.utc_now()
      )

    {:ok, comment3} =
      Publishing.Comment.create(
        id: uuid(),
        post_id: post.id,
        author_id: author.id,
        body: "comment 3",
        published_at: DateTime.utc_now()
      )

    context
    |> Map.put(:author, author)
    |> Map.put(:blog, blog)
    |> Map.put(:post, post)
    |> Map.put(:comment1, comment1)
    |> Map.put(:comment2, comment2)
    |> Map.put(:comment3, comment3)
  end
end
