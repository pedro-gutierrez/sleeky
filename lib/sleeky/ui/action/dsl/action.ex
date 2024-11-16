defmodule Sleeky.Ui.Action.Dsl.Action do
  @moduledoc false
  use Diesel.Tag

  tag do
    attribute :name, kind: :module
    child :on, min: 1
  end
end
