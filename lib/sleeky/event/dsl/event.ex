defmodule Sleeky.Event.Dsl.Event do
  @moduledoc false
  use Diesel.Tag

  tag do
    attribute :version, kind: :integer, required: false, default: 1
    child :field, min: 1
  end
end
