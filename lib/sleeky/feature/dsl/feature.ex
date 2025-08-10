defmodule Sleeky.Feature.Dsl.Feature do
  @moduledoc false
  use Diesel.Tag

  tag do
    child :models, min: 1, max: 1
    child :scopes, min: 0, max: 1
    child :commands, min: 0, max: 1
    child :queries, min: 0, max: 1
    child :handlers, min: 0, max: 1
    child :events, min: 0, max: 1
    child :subscriptions, min: 0, max: 1
  end
end
