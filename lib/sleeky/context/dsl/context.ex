defmodule Sleeky.Context.Dsl.Context do
  @moduledoc false
  use Diesel.Tag

  tag do
    child :entities, min: 1, max: 1
    child :scopes, min: 0, max: 1
  end
end
