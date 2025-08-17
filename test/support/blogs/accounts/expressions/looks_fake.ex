defmodule Blogs.Accounts.Expressions.LooksFake do
  @moduledoc false

  def execute(user, _context), do: String.contains?(user.email, "fake")
end
