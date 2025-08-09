defmodule Blogs.Accounts.Projections.UserDetails do
  @moduledoc false

  use Sleeky.Projection

  projection do
    field :id, type: :id
    field :email, type: :string
  end
end
