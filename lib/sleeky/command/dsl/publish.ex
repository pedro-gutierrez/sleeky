defmodule Sleeky.Command.Dsl.Publish do
  @moduledoc false
  use Diesel.Tag

  tag do
    attribute :name, kind: :module, required: true
    attribute :from, kind: :module, required: true
  end
end
