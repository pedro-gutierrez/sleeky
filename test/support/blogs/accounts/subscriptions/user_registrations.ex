defmodule Blogs.Accounts.Subscriptions.UserRegistrations do
  @moduledoc false
  use Sleeky.Subscription

  subscription(
    on: Blogs.Accounts.Events.UserRegistered,
    perform: Blogs.Accounts.Flows.Onboarding
  )
end
