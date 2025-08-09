defmodule Blogs.Accounts.Scopes.SameEmail do
  @moduledoc false
  use Sleeky.Scope

  scope do
    same do
      path "params.user_email"
      path "email"
    end
  end
end
