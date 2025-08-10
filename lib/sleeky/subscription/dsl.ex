defmodule Sleeky.Subscription.Dsl do
  @moduledoc false
  use Diesel.Dsl,
    otp_app: :sleeky,
    root: Sleeky.Subscription.Dsl.Subscription,
    tags: [
      Sleeky.Subscription.Dsl.Command
    ]
end
