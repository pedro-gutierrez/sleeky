defmodule Sleeky.Subscription do
  @moduledoc """
  A DSL to define event subscriptions and their associated command handlers
  """

  use Diesel,
    otp_app: :sleeky,
    dsl: Sleeky.Subscription.Dsl,
    parser: Sleeky.Subscription.Parser,
    generators: [
      Sleeky.Subscription.Generator.Metadata,
      Sleeky.Subscription.Generator.Execute
    ]

  defstruct [:name, :feature, :event, :action]

  def execute(subscription, params) do
    params = Map.from_struct(params)
    feature = subscription.feature()
    fun = subscription.action().fun_name()

    apply(feature, fun, [params])
  end
end
