defmodule Blogs.Accounts.Queries.GetUsers do
  @moduledoc false
  use Sleeky.Query

  alias Blogs.Accounts.User
  alias Blogs.Accounts.Scopes.IsPublic

  query returns: User, many: true do
    policy role: :guest, scope: IsPublic
  end
end
