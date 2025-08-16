defmodule Sleeky.Mapping.Dsl.Field do
  @moduledoc false
  use Diesel.Tag

  tag do
    attribute :name, kind: :atom, required: true
    attribute :path, kind: :string, required: true
  end
end
