defmodule Blogs.Notifications do
  @moduledoc false
  use Sleeky.Domain

  domain do
    models do
      Blogs.Notifications.Digest
    end
  end
end
