defmodule Blog.Case do
  use Bee.Entity

  attribute :name, :string do
  end

  belongs_to(:user)

  unique(:name)

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
