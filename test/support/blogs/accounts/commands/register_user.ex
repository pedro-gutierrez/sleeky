defmodule Blogs.Accounts.Commands.RegisterUser do
  @moduledoc false

  use Sleeky.Command

  alias Blogs.Accounts.User
  alias Blogs.Accounts.Events.UserRegistered
  alias Blogs.Accounts.Tasks.CreateUser

  command params: User, atomic: true do
    policy role: :guest

    step :registering do
      task name: CreateUser
    end

    step :registered do
      event name: UserRegistered
    end
  end
end
