defmodule Blogs.Notifications do
  @moduledoc false
  use Sleeky.Domain

  domain do
    model Blogs.Notifications.Digest
  end
end
