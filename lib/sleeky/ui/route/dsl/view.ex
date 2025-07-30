defmodule Sleeky.Ui.Route.Dsl.View do
  @moduledoc false
  use Diesel.Tag

  tag do
    attribute :name, kind: :module, required: false
    attribute :for, kind: :string, required: false, default: "default"
    child kind: :module, min: 0, max: 1
  end
end
