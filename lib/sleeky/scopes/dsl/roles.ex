defmodule Sleeky.Scopes.Dsl.Roles do
  @moduledoc false
  use Diesel.Tag

  tag do
    attribute name: :path, kind: :string
  end
end
