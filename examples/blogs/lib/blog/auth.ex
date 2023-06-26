defmodule Blog.Auth do
  use Bee.Auth

  roles([:current_user, :roles])

  scope :owner do
    "**.user" == "current_user.id"
  end

  scope(:self, "id" == "current_user.id")
end
