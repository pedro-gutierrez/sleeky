defmodule Blogs.Accounts.Queries.GetUserByEmail do
  @moduledoc false
  use Sleeky.Query

  alias Blogs.Accounts.User
  alias Blogs.Accounts.Values.UserEmail

  query params: UserEmail, returns: User do
    policy role: :user
  end
end
