defmodule Blog.Content do
  use Bee.Context, repo: Blog.Repo

  enum(Blog.Sentiment)

  entity(Blog.Post)
  entity(Blog.Comment)
  entity(Blog.Tag)
end
