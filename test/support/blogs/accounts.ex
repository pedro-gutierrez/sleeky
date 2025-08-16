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
      Blogs.Accounts.Commands.EnableUser
      Blogs.Accounts.Commands.SendWelcomeEmail
      Blogs.Accounts.Commands.RequestFeedback
    end

    queries do
      Blogs.Accounts.Queries.GetOnboardings
      Blogs.Accounts.Queries.GetUsers
      Blogs.Accounts.Queries.GetUserByEmail
      Blogs.Accounts.Queries.GetUserIds
    end

    scopes do
      Blogs.Accounts.Scopes.Self
    end

    events do
      Blogs.Accounts.Events.UserRegistered
      Blogs.Accounts.Events.PasswordRemindedSent
      Blogs.Accounts.Events.UserOnboarded
    end

    flows do
      Blogs.Accounts.Flows.Onboarding
    end

    subscriptions do
      Blogs.Accounts.Subscriptions.UserRegistrations
      Blogs.Accounts.Subscriptions.UserOnboardings
    end

    mappings do
      Blogs.Accounts.Mappings.UserRegisteredFromUser
      Blogs.Accounts.Mappings.UserOnboardedFromOnboarding
    end
  end
end
