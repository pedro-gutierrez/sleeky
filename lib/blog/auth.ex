defmodule Blog.Auth do
  use Bee.Auth, schema: Blog.Schema

  roles([:current_user, :roles])
end
