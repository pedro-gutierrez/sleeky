defmodule Blog.User do
  use Bee.Entity

  attribute :email, :string do
  end

  has_many(:cases)

  unique(:email)

  action :list do
    allow(:admin, :any)
  end

  action(:read) do
    allow(:admin, :any)
  end

  action :create do
    allow(:admin, :any)
  end

  action :update do
    allow(:admin, :any)
  end

  action :delete do
    allow(:admin, :any)
  end
end
