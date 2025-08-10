defmodule Sleeky.Command.Dsl.Task do
  @moduledoc false
  use Diesel.Tag

  tag do
    attribute :name, kind: :module, required: true
  end
end
