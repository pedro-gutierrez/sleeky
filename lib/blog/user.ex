defmodule Blog.User do
  use Bee.Entity

  attribute :email, :string do
    unique()
  end

  has_many(:posts)
  has_many(:comments)
end
