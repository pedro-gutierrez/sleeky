defmodule Blog.Schema.Post do
  use Bee.Entity

  attribute :title, :string do
  end

  slug(:title)

  belongs_to(:blog)
  has_many(:comments)

  key([:blog, :title])

  action :list do
    allow(:admin, :any)
  end

  action :read do
    allow(:admin, :any)
  end

  action :create do
    allow(:admin, :any)
  end

  action :update do
    allow(:admin, :any)
  end
end
