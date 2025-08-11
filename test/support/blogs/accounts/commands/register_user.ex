defmodule Blogs.Accounts.Commands.RegisterUser do
  @moduledoc false

  use Sleeky.Command

  alias Blogs.Accounts.User
  alias Blogs.Accounts.Events.UserRegistered

  command params: User, atomic: true do
    policy role: :guest

    publish(event: UserRegistered)
  end
end
