defmodule Sleeky.Mapping.Dsl.Mapping do
  @moduledoc false
  use Diesel.Tag

  tag do
    attribute :from, kind: :module, required: true
    attribute :to, kind: :module, required: true
    child :field, min: 1
  end
end
