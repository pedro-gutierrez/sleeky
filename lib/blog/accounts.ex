defmodule Blog.Accounts do
  use Bee.Context, repo: Blog.Repo, auth: Blog.Auth

  entity(Blog.User)
end
