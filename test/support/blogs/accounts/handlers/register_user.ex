defmodule Blogs.Accounts.Handlers.RegisterUser do
  @moduledoc false

  def execute(%{email: "foo@bar.com"}, _context), do: {:error, :invalid_email}
  def execute(user, context), do: Blogs.Accounts.create_user(user, context)
end
