defmodule Blogs.JsonApi do
  @moduledoc false
  use Sleeky.JsonApi

  json_api do
    context Blogs.Publishing
  end
end
