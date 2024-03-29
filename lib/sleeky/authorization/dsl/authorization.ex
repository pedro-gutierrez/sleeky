defmodule Sleeky.Authorization.Dsl.Authorization do
  @moduledoc false
  use Diesel.Tag

  tag do
    attribute :roles, required: true
    child :scope, min: 1
  end
end
