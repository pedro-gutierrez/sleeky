defmodule Sleeky.Api.Dsl.Plugs do
  @moduledoc false
  use Diesel.Tag

  tag do
    child kind: :module, min: 1, max: 1
  end
end
