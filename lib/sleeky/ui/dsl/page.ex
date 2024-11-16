defmodule Sleeky.Ui.Dsl.Page do
  @moduledoc false
  use Diesel.Tag

  tag do
    attribute :name, kind: :module
    attribute :at, kind: :string
  end
end
