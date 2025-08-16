defmodule Sleeky.Scope.Dsl.One do
  @moduledoc false
  use Diesel.Tag

  tag do
    child kind: :any, min: 1
  end
end
