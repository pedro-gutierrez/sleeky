defmodule Sleeky.Scope.Dsl.All do
  @moduledoc false
  use Diesel.Tag

  tag do
    child kind: :any, min: 1
  end
end
