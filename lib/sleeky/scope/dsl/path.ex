defmodule Sleeky.Scope.Dsl.Path do
  @moduledoc false
  use Diesel.Tag

  tag do
    child kind: :string, min: 1, max: 1
  end
end
