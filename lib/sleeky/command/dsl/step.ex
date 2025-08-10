defmodule Sleeky.Command.Dsl.Step do
  @moduledoc false
  use Diesel.Tag

  tag do
    attribute :name, kind: :atom, required: true
    child :task, min: 0
    child :event, min: 0
  end
end
