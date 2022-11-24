defmodule Blog.Schema do
  use Bee.Schema

  add(Blog.User)
  add(Blog.Post)
  add(Blog.Comment)
  add(Blog.Tag)
  add(Blog.Vote)
end
