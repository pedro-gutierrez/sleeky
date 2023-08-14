defmodule TestApp.Auth do
  use Sleeky.Auth

  roles([:actor, :roles])
end
