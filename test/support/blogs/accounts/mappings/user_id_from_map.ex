defmodule Blogs.Accounts.Mappings.UserIdFromMap do
  @moduledoc false
  use Sleeky.Mapping

  alias Blogs.Accounts.Values.UserId

  mapping from: Map, to: UserId do
    field :user_id, path: "id"
  end
end
