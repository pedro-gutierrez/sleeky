defmodule Sleeky.Authorization.Dsl.Equal do
  @moduledoc false
  use Diesel.Tag

  tag do
    child kind: :string, min: 2, max: 2
  end
end
