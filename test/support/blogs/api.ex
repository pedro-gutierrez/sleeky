defmodule Blogs.Api do
  @moduledoc false
  use Sleeky.Api

  api do
    plugs do
      Blogs.FakeAuth
    end

    features do
      Blogs.Publishing
    end
  end
end
