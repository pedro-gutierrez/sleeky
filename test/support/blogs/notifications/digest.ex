defmodule Blogs.Notifications.Digest do
  @moduledoc false
  use Sleeky.Entity

  entity virtual: true do
    attribute name: :text, kind: :string
    attribute name: :section, kind: :string
  end
end
