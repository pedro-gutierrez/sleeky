defmodule Blogs.Accounts.Events.UserOnboarded do
  @moduledoc false
  use Sleeky.Event

  event do
    field :user_id, type: :id, required: true
    field :onboarded_at, type: :datetime, required: true
  end
end
