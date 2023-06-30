defmodule Blog.Schema.Credential do
  use Bee.Entity

  attribute :public_key, :string do
  end

  belongs_to(:user)
end
