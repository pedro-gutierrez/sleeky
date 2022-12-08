defmodule Blog.Feedback do
  use Bee.Context, repo: Blog.Repo, auth: Blog.Auth

  entity(Blog.Vote)
end
