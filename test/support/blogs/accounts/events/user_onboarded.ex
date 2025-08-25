defmodule Blogs.Accounts.Events.UserOnboarded do
  @moduledoc false
  use Sleeky.Event

  event do
    field :user_id, type: :id, required: true
  end
end
