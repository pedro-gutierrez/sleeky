defmodule Sleeky.Ui.Namespace.Dsl.Namespace do
  @moduledoc false
  use Diesel.Tag

  tag do
    attribute :name, kind: :string
    child :routes, min: 1, max: 1
  end
end
