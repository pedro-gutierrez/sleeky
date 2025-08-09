defmodule Blogs.Accounts.Scopes.IsPublic do
  @moduledoc false
  use Sleeky.Scope

  scope do
    is_true do
      path "public"
    end
  end
end
