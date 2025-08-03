defmodule Sleeky.Entity.Dsl.All do
  @moduledoc false

  use Diesel.Tag

  tag do
    child kind: :atom, min: 0
  end
end
