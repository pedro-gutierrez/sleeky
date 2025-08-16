defmodule Sleeky.Subscription.Dsl.Subscription do
  @moduledoc false
  use Diesel.Tag

  tag do
    attribute :on, kind: :module, required: true
    attribute :perform, kind: :module, required: true
  end
end
