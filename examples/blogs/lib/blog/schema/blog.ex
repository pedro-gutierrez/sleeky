defmodule Blog.Schema.Blog do
  use Bee.Entity

  attribute :name, :string do
  end

  unique(:name)

  belongs_to(:user)
  has_many(:posts)

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
