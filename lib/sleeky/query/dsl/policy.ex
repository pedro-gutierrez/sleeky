defmodule Sleeky.Query.Dsl.Policy do
  @moduledoc false
  use Diesel.Tag

  tag do
    attribute :role, kind: :atom, required: true
    attribute :scope, kind: :atom, required: false
    child :scope, min: 0
  end
end
