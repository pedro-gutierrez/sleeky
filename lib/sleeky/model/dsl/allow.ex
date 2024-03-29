defmodule Sleeky.Model.Dsl.Allow do
  @moduledoc false

  use Diesel.Tag

  tag do
    attribute :role, kind: :atom, required: true
    attribute :scope, kind: :atom, required: false
  end
end
