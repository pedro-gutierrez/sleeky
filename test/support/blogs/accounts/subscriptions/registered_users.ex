defmodule Blogs.Accounts.Subscriptions.RegisteredUsers do
  @moduledoc false
  use Sleeky.Subscription

  subscription(
    on: Blogs.Accounts.Events.UserRegistered,
    perform: Blogs.Accounts.Flows.Onboarding
  )
end
