defmodule Sleeky.Flow.Dsl.Flow do
  @moduledoc false
  use Diesel.Tag

  tag do
    attribute :model, kind: :module, required: true
    attribute :params, kind: :module, required: false
    attribute :publish, kind: :module, required: true
    child :steps, min: 1
  end
end
