defmodule Blogs.Accounts.Events.UsersLocked do
  @moduledoc false

  use Sleeky.Event

  event do
    field :user_ids, type: :string, many: true
  end
end
