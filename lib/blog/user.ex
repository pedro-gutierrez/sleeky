defmodule Blog.User do
  use Bee.Entity

  attribute :email, :string do
  end

  attribute(:app, :string)

  has_many(:posts)
  has_many(:comments)

  unique(:email)
  # unique([:email, :app])

  action :list do
    allow(:admin, :self)
  end

  action(:read)

  action :create do
    allow(:admin, :any)
  end

  action(:update)
  action(:delete)
end
