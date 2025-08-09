defmodule Blogs.Accounts.Scopes.Self do
  @moduledoc false
  use Sleeky.Scope

  scope do
    same do
      path "user.id"
      path "current_user.id"
    end
  end
end
