defmodule Sleeky.Model.Dsl.Task do
  @moduledoc false

  use Diesel.Tag

  tag do
    child kind: :module, min: 0, max: 1
    attribute :name, kind: :module, required: false
    attribute :if, kind: :module, required: false
  end
end
