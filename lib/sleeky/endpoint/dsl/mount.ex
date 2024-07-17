defmodule Sleeky.Endpoint.Dsl.Mount do
  @moduledoc false
  use Diesel.Tag

  tag do
    attribute :name, kind: :module, required: true
    attribute :at, kind: :string, required: true
  end
end
