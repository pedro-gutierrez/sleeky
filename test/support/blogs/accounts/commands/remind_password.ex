defmodule Blogs.Accounts.Commands.RemindPassword do
  @moduledoc false

  use Sleeky.Command

  alias Blogs.Accounts.Scopes.SelfAndNotLocked
  alias Blogs.Accounts.Values.UserId

  command params: UserId do
    policy role: :user, scope: SelfAndNotLocked
  end
end
