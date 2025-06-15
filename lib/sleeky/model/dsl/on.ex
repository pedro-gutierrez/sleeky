defmodule Sleeky.Model.Dsl.On do
  @moduledoc false

  use Diesel.Tag

  tag do
    attribute name: :*, kind: :*, min: 1
    child kind: :module, min: 1
  end
end
