defmodule Blog.Auth do
  use Bee.Auth

  roles([:current_user, :roles])
end
