defmodule Blogs.Accounts.Commands.RegisterUser do
  @moduledoc false

  use Sleeky.Command

  alias Blogs.Accounts.User

  command params: User, atomic: true do
    policy role: :guest
  end
end
