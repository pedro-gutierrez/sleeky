defmodule Blogs.Notifications do
  @moduledoc false
  use Sleeky.Feature

  feature do
    models do
      Blogs.Notifications.Digest
    end
  end
end
