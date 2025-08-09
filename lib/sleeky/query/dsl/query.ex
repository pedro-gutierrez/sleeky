defmodule Sleeky.Query.Dsl.Query do
  @moduledoc false
  use Diesel.Tag

  tag do
    attribute :params, kind: :module, required: false
    attribute :returns, kind: :module, required: true
    attribute :limit, kind: :integer, required: false
    attribute :many, kind: :boolean, required: false, default: false
    child :policy, min: 0
  end
end
