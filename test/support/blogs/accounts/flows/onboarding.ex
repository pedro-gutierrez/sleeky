defmodule Blogs.Accounts.Flows.Onboarding do
  @moduledoc false
  use Sleeky.Flow

  alias Blogs.Accounts.Commands.SendWelcomeEmail
  alias Blogs.Accounts.Commands.EnableUser

  alias Blogs.Accounts.Onboarding
  alias Blogs.Accounts.Values.UserId
  alias Blogs.Accounts.Events.UserOnboarded

  flow model: Onboarding, params: UserId, publish: UserOnboarded do
    steps do
      SendWelcomeEmail
      EnableUser
    end
  end
end
