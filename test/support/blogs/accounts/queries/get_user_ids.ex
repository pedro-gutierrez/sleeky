defmodule Blogs.Accounts.Queries.GetUserIds do
  @moduledoc false
  use Sleeky.Query

  alias Blogs.Accounts.Values.UserId

  query returns: UserId, many: true, custom: true do
    policy role: :user
  end

  def execute(_context), do: [%{"id" => Ecto.UUID.generate()}]
end
