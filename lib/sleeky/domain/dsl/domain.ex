defmodule Sleeky.Domain.Dsl.Domain do
  @moduledoc false
  use Diesel.Tag

  tag do
    child :models, min: 1, max: 1
    child :scopes, min: 0, max: 1
  end
end
