defmodule Blogs.Accounts.Events.UserRegistered do
  @moduledoc false

  use Sleeky.Event

  event do
    field :user_id, type: :id
    field :registered_at, type: :datetime
  end
end
