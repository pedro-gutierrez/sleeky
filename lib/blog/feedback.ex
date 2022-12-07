defmodule Blog.Feedback do
  use Bee.Context, repo: Blog.Repo

  entity(Blog.Vote)
end
