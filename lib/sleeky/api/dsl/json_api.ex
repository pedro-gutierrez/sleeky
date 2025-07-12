defmodule Sleeky.Api.Dsl.Api do
  @moduledoc false
  use Diesel.Tag

  tag do
    child :context, min: 1
    child :plugs, min: 0, max: 1
  end
end
