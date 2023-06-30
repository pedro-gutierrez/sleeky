defmodule Blog.Schema.Registration do
  use Bee.Entity,
    breadcrumbs: false

  attribute :username, :string do
  end

  action :create do
    allow(:admin, :any)
  end
end
