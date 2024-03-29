defmodule Sleeky.Authorization.Dsl.Eq do
  @moduledoc false
  use Diesel.Tag

  tag do
    child kind: :any, min: 2, max: 2
  end
end
