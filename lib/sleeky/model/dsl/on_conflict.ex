defmodule Sleeky.Model.Dsl.OnConflict do
  @moduledoc false

  use Diesel.Tag

  tag do
    attribute :strategy, kind: :atom, in: [:merge, :ignore, :raise], required: true
    attribute :except, kind: :atoms, required: false
  end
end
