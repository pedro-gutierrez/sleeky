defmodule Blog.Schema do
  use Bee.Schema

  add(Blog.User)
  add(Blog.Post)
end
