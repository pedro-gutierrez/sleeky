defmodule Sleeky.Command.Dsl.Publish do
  @moduledoc false
  use Diesel.Tag

  tag do
    attribute :event, kind: :module, required: true
    attribute :from, kind: :module, required: false
    attribute :if, kind: :module, required: false
    attribute :unless, kind: :module, required: false
  end
end
