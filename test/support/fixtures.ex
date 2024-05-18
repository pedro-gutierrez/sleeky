defmodule Sleeky.Fixtures do
  @moduledoc false

  alias Blogs.Accounts
  alias Blogs.Publishing

  def user(context) do
    {:ok, user} = Accounts.User.create(id: Ecto.UUID.generate(), email: "foo@bar", public: true)
    user = Map.put(user, :roles, [:user])

    Map.put(context, :user, user)
  end

  def comment(context) do
    {:ok, author} = Publishing.Author.create(id: context.user.id, name: "foo")

    {:ok, blog} =
      Publishing.Blog.create(
        id: Ecto.UUID.generate(),
        published: true,
        author_id: author.id,
        name: "elixir blog"
      )

    {:ok, post} =
      Publishing.Post.create(
        id: Ecto.UUID.generate(),
        blog_id: blog.id,
        published: true,
        deleted: false,
        title: "first post",
        locked: false,
        published_at: DateTime.utc_now()
      )

    {:ok, comment} =
      Publishing.Comment.create(
        id: Ecto.UUID.generate(),
        post_id: post.id,
        author_id: author.id,
        body: "some comment",
        published_at: DateTime.utc_now()
      )

    context
    |> Map.put(:author, author)
    |> Map.put(:blog, blog)
    |> Map.put(:post, post)
    |> Map.put(:comment, comment)
  end
end
