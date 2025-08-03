defmodule Sleeky.Entity.Dsl.Role do
  @moduledoc false

  use Diesel.Tag

  tag do
    attribute :name, kind: :atom, required: false
    attribute :scope, kind: :atom, required: false
    child :scope, min: 0
    child kind: :atom, min: 0, max: 1
  end
end
