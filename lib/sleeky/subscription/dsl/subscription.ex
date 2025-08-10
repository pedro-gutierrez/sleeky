defmodule Sleeky.Subscription.Dsl.Subscription do
  @moduledoc false
  use Diesel.Tag

  tag do
    attribute :to, kind: :module, required: true
    child :command, min: 1, max: 1
  end
end
