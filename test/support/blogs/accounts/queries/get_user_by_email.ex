defmodule Blogs.Accounts.Queries.GetUserByEmail do
  @moduledoc false
  use Sleeky.Query

  alias Blogs.Accounts.User
  alias Blogs.Accounts.Values.UserEmail
  import Ecto.Query

  query params: UserEmail, returns: User do
    policy role: :user
  end

  def execute(q, params, _context) do
    where(q, [u], u.email == ^params.user_email)
  end
end
