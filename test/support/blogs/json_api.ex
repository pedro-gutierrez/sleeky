defmodule Blogs.JsonApi do
  @moduledoc false
  use Sleeky.JsonApi

  json_api do
    plugs [Blogs.FakeAuth]

    context Blogs.Publishing
  end
end
