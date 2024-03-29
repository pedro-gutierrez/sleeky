defmodule Sleeky.Authorization.Dsl.Scope do
  @moduledoc false
  use Diesel.Tag

  tag do
    attribute :name, kind: :atom, required: true
    attribute :debug, kind: :boolean, required: false, default: false
    child :eq, min: 0, max: 1
    child :one, min: 0, max: 1
    child :all, min: 0, max: 1
    child :not_nil, min: 0, max: 1
  end
end
