defmodule Sleeky.Entity.Dsl.Scope do
  @moduledoc false

  use Diesel.Tag

  tag do
    child :one, min: 0
    child :all, min: 0
  end
end
