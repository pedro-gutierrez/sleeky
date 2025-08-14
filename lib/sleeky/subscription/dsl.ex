defmodule Sleeky.Subscription.Dsl do
  @moduledoc false
  use Diesel.Dsl,
    otp_app: :sleeky,
    tags: [Sleeky.Subscription.Dsl.Subscription]
end
