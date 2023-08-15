defmodule TestApp.Schema.User do
  use Sleeky.Entity

  attribute :email, :string
  has_many(:blogs)
end
