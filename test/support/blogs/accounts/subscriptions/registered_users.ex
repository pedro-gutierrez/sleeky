defmodule Blogs.Accounts.Subscriptions.RegisteredUsers do
  @moduledoc false

  use Sleeky.Subscription

  alias Blogs.Accounts.Events.UserRegistered
  alias Blogs.Accounts.Commands.RemindPassword

  subscription to: UserRegistered do
    command RemindPassword
  end
end
