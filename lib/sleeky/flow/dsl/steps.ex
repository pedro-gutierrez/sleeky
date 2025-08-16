defmodule Sleeky.Flow.Dsl.Steps do
  @moduledoc false
  use Diesel.Tag

  tag do
    child kind: :module, min: 1
  end
end
