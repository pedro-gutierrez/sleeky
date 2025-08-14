defmodule Blogs.Accounts do
  @moduledoc false
  use Sleeky.Feature

  feature do
    models do
      Blogs.Accounts.User
      Blogs.Accounts.Onboarding
    end

    commands do
      Blogs.Accounts.Commands.RegisterUser
      Blogs.Accounts.Commands.RemindPassword
    end

    queries do
      Blogs.Accounts.Queries.GetAllUsers
      Blogs.Accounts.Queries.GetUserByEmail
      Blogs.Accounts.Queries.GetUserIds
    end

    scopes do
      Blogs.Accounts.Scopes.Self
    end

    events do
      Blogs.Accounts.Events.UserRegistered
      Blogs.Accounts.Events.PasswordRemindedSent
    end

    flows do
      Blogs.Accounts.Flows.Onboarding
    end

    subscriptions do
      Blogs.Accounts.Subscriptions.RegisteredUsers
    end
  end
end
