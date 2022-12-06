defmodule Blog.Schema do
  use Bee.Schema

  context(Blog.Accounts)
  context(Blog.Content)
  context(Blog.Feedback)
end
