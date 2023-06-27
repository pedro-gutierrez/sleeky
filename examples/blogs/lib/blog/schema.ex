defmodule Blog.Schema do
  use Bee.Schema

  entity(Blog.Schema.User)
  entity(Blog.Schema.Blog)
  entity(Blog.Schema.Post)
  entity(Blog.Schema.Comment)
end
