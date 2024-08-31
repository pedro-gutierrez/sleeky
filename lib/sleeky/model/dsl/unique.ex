defmodule Sleeky.Model.Dsl.Unique do
  @moduledoc false

  use Diesel.Tag

  tag do
    child kind: :atom, min: 1
  end
end
