defmodule Sleeky.Model.Dsl.Action do
  @moduledoc false
  use Diesel.Tag

  tag do
    attribute :name, kind: :atom, required: true
    child :allow, min: 0
  end
end
