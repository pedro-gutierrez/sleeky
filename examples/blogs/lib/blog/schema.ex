defmodule Blog.Schema do
  use Bee.Schema

  entity(Blog.Schema.Blog)
  entity(Blog.Schema.Comment)
  entity(Blog.Schema.Credential)
  entity(Blog.Schema.Login)
  entity(Blog.Schema.Post)
  entity(Blog.Schema.Registration)
  entity(Blog.Schema.User)
end
