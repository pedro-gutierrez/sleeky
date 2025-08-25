defmodule Blogs.Accounts.Queries.GetUsersByEmails do
  @moduledoc false
  use Sleeky.Query

  alias Blogs.Accounts.User
  alias Blogs.Accounts.Values.UserEmails

  query params: UserEmails, returns: User, many: true do
    policy role: :user
  end
end
