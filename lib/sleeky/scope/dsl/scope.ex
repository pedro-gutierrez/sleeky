defmodule Sleeky.Scope.Dsl.Scope do
  @moduledoc false
  use Diesel.Tag

  tag do
    attribute :debug, kind: :boolean, required: false, default: false
    child :eq, min: 0, max: 1
    child :one, min: 0, max: 1
    child :all, min: 0, max: 1
    child :not_nil, min: 0, max: 1
    child :is_true, min: 0, max: 1
    child :is_false, min: 0, max: 1
    child :member, min: 0, max: 1
    child :same, min: 0, max: 1
  end
end
