defmodule Sleeky.Authorization.Dsl.Scope do
  @moduledoc false
  use Diesel.Tag

  tag do
    attribute :name, kind: :atom
    child :equal, min: 0, max: 1
  end
end
