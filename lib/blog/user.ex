defmodule Blog.User do
  use Bee.Entity

  attribute :email, :string do
  end

  has_many(:posts)
  has_many(:comments)

  unique(:email)
end
