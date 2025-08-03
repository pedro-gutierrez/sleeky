defmodule Sleeky.Api.Dsl.Api do
  @moduledoc false
  use Diesel.Tag

  tag do
    child :contexts, min: 1, max: 1
    child :plugs, min: 0, max: 1
  end
end
