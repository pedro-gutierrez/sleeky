defmodule Blogs.Notifications.Digest do
  @moduledoc false
  use Sleeky.Model

  model virtual: true do
    attribute name: :text, kind: :string
    attribute name: :section, kind: :string
  end
end
