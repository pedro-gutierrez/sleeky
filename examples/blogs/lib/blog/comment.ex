defmodule Blog.Comment do
  use Bee.Entity

  attribute :text, :text do
  end

  attribute :sentiment, :enum do
    one_of(:sentiment)
  end

  belongs_to(:post)
  belongs_to(:user)
  has_many(:votes)

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
