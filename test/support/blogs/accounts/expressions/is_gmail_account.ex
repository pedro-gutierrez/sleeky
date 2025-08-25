defmodule Blogs.Accounts.Expressions.IsGmailAccount do
  @moduledoc false

  def execute(user, _context), do: String.ends_with?(user.email, "gmail.com")
end
