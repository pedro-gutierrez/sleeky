defmodule Sleeky.Ui.Action.Dsl.On do
  @moduledoc false
  use Diesel.Tag

  tag do
    attribute :name, kind: :atom
    attribute :view, kind: :module, required: false
    attribute :redirect, kind: :string, required: false
  end
end
