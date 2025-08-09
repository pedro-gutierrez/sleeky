defmodule Blogs.Accounts.Scopes.NotLocked do
  @moduledoc false
  use Sleeky.Scope

  scope do
    is_false do
      path "user.locked"
    end
  end
end
