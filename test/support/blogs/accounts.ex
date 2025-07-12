defmodule Blogs.Accounts do
  @moduledoc false
  use Sleeky.Context

  context do
    model Blogs.Accounts.User
    scopes(Blogs.Scopes)
  end
end
