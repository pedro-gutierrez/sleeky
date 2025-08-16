defmodule Blogs.Accounts.Values.UserEmail do
  @moduledoc false
  use Sleeky.Value

  value do
    field :email, type: :string
  end
end
