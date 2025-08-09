defmodule Sleeky.Projection.Dsl.Projection do
  @moduledoc false
  use Diesel.Tag

  tag do
    child :field, min: 1
  end
end
