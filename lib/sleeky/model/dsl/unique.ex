defmodule Sleeky.Model.Dsl.Unique do
  @moduledoc false

  use Diesel.Tag

  tag do
    attribute :fields, kind: :atoms, required: true
    child :on_conflict, min: 0, max: 1
  end
end
