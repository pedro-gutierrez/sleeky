defmodule Blog.Content do
  use Bee.Context, repo: Blog.Repo, auth: Blog.Auth

  enum(Blog.Sentiment)

  entity(Blog.Post)
  entity(Blog.Comment)
  entity(Blog.Tag)
end
