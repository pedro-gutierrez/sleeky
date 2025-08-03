defmodule Blogs.Api do
  @moduledoc false
  use Sleeky.Api

  api do
    plugs do
      Blogs.FakeAuth
    end

    contexts do
      Blogs.Publishing
    end
  end
end
