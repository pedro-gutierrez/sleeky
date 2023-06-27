defmodule Blog.Schema.Comment do
  use Bee.Entity

  attribute :text, :text do
  end

  belongs_to(:post)

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
