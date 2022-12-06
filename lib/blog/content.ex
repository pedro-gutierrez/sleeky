defmodule Blog.Content do
  use Bee.Context

  enum(Blog.Sentiment)

  entity(Blog.Post)
  entity(Blog.Comment)
  entity(Blog.Tag)
end
