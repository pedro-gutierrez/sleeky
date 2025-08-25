defmodule Blogs.Accounts.Events.UserRegistered do
  @moduledoc false

  use Sleeky.Event

  event version: 1 do
    field :user_id, type: :id, required: true
    field :registered_at, type: :datetime, required: true
  end
end
