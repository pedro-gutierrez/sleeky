defmodule Blog.Post do
  use Bee.Entity

  attribute :subject, :string do
  end

  slug(:subject)

  belongs_to(:user)
  has_many(:comments)
  has_many(:tags)

  key([:user, :subject])

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
