defmodule Blog.Accounts do
  use Bee.Context, repo: Blog.Repo

  entity(Blog.User)
end
