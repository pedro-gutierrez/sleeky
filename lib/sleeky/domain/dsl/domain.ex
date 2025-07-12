defmodule Sleeky.Domain.Dsl.Domain do
  @moduledoc false
  use Diesel.Tag

  tag do
    child :model, min: 1
    child :scopes, min: 0, max: 1
  end
end
