defmodule Sleeky.Subscription do
  @moduledoc """
  A DSL to define event subscriptions and their associated command handlers
  """

  use Diesel,
    otp_app: :sleeky,
    dsl: Sleeky.Subscription.Dsl,
    parser: Sleeky.Subscription.Parser,
    generators: [
      Sleeky.Subscription.Generator.Metadata
    ]

  defstruct [:name, :feature, :event, :commands]
end
