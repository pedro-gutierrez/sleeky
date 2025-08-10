defmodule Sleeky.Command.Dsl.Command do
  @moduledoc false
  use Diesel.Tag

  tag do
    attribute :params, kind: :module, required: false
    attribute :atomic, kind: :boolean, required: false, default: false
    child :policy, min: 0
    child :step, min: 0
  end
end
