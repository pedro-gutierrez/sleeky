defmodule Blog.Schema do
  use Bee.Schema

  enum(Blog.Sentiment)

  entity(Blog.User)
  entity(Blog.Post)
  entity(Blog.Comment)
  entity(Blog.Tag)
  entity(Blog.Vote)
end
