defmodule Blog.Post do
  use Bee.Entity

  attribute :subject, :string do
  end

  slug(:subject)

  belongs_to(:user)
  has_many(:comments)
  has_many(:tags)
end
