defmodule Blogs.Accounts.Events.PasswordRemindedSent do
  @moduledoc false

  use Sleeky.Event

  event do
    field :user_id, type: :id
    field :reminded_at, type: :datetime
  end
end
