defmodule Blog.Vote do
  use Bee.Entity

  attribute :vote, :integer do
    immutable()
  end

  belongs_to(:comment)
  belongs_to(:user)
end
