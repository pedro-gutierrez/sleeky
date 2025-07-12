defmodule Sleeky.Scopes.Dsl.IsTrue do
  @moduledoc false
  use Diesel.Tag

  tag do
    child kind: :any, min: 1, max: 1
  end
end
