defmodule Blogs.Accounts.Queries.GetUserByEmail do
  @moduledoc false
  use Sleeky.Query

  alias Blogs.Accounts.Scopes.SameEmail
  alias Blogs.Accounts.Projects.UserDetails
  alias Blogs.Accounts.Values.UserEmail

  query params: UserEmail, returns: UserDetails, many: false do
    policy role: :guest, scope: SameEmail
  end
end
