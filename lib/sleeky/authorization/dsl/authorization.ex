defmodule Sleeky.Authorization.Dsl.Authorization do
  @moduledoc false
  use Diesel.Tag

  tag do
    child :roles, min: 1, max: 1
    child :scope, min: 1
  end
end
