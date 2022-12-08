defmodule Blog.User do
  use Bee.Entity

  attribute :email, :string do
  end

  attribute(:app, :string)

  has_many(:posts)
  has_many(:comments)

  unique(:email)
  # unique([:email, :app])

  action(:list)
end
