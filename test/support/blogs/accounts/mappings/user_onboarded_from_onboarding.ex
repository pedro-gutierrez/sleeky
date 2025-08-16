defmodule Blogs.Accounts.Mappings.UserOnboardedFromOnboarding do
  @moduledoc false
  use Sleeky.Mapping

  alias Blogs.Accounts.Onboarding
  alias Blogs.Accounts.Events.UserOnboarded

  mapping from: Onboarding, to: UserOnboarded do
    field :user_id, path: "user_id"
    field :onboarded_at, path: "inserted_at"
  end
end
