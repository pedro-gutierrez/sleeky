defmodule Sleeky.Entity.Dsl.Action do
  @moduledoc false
  use Diesel.Tag

  tag do
    attribute :name, kind: :atom, required: true
    child :allow, min: 0
    child :role, min: 0
    child :on, min: 0
  end
end
