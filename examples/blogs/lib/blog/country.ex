defmodule Blog.Country do
  use Bee.Entity

  attribute :code, :string do
  end

  action :list do
    allow(:admin, :any)
  end
end
