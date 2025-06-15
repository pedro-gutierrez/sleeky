defmodule Sleeky.Authorization.Dsl.Authorization do
  @moduledoc false
  use Diesel.Tag

  tag do
    attribute :roles, kind: :string, required: true
    child :scope, min: 1
  end
end
