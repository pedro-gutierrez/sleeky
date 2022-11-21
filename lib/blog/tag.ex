defmodule Blog.Tag do
  use Bee.Entity

  attribute(:name, :string)
  belongs_to(:post)
end
