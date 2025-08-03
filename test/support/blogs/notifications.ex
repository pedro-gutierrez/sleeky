defmodule Blogs.Notifications do
  @moduledoc false
  use Sleeky.Context

  context do
    entities do
      Blogs.Notifications.Digest
    end
  end
end
