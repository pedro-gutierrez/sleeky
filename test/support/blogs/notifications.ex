defmodule Blogs.Notifications do
  @moduledoc false
  use Sleeky.Context

  context do
    models do
      Blogs.Notifications.Digest
    end
  end
end
