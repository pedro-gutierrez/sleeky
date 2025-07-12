defmodule Blogs.Api do
  @moduledoc false
  use Sleeky.Api

  api do
    plugs [Blogs.FakeAuth]

    context Blogs.Publishing
  end
end
