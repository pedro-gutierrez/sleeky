defmodule Blogs.Accounts.Handlers.GetUserByEmail do
  @moduledoc false

  import Ecto.Query

  def execute(q, params, _context) do
    where(q, [u], u.email == ^params.user_email)
  end
end
