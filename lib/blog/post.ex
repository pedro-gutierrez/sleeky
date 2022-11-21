defmodule Blog.Post do
  use Bee.Entity

  attribute :subject, :string do
  end

  belongs_to(:user)
  has_many(:comments)
  has_many(:tags)
end
