defmodule Sleeky.Query.Dsl.Sort do
  @moduledoc false
  use Diesel.Tag

  tag do
    attribute :by, kind: :atom, required: true
    attribute :direction, kind: :atom, required: false, in: [:asc, :desc], default: :asc
  end
end
