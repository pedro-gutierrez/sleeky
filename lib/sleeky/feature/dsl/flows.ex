defmodule Sleeky.Feature.Dsl.Flows do
  @moduledoc false
  use Diesel.Tag

  tag do
    child kind: :module, min: 1
  end
end
