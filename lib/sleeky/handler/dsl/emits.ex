defmodule Sleeky.Handler.Dsl.Emits do
  @moduledoc false
  use Diesel.Tag

  tag do
    attribute :name, kind: :module, required: true
    attribute :public, kind: :boolean, default: false
  end
end
