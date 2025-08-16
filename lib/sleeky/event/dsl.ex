defmodule Sleeky.Event.Dsl do
  @moduledoc false
  use Diesel.Dsl,
    otp_app: :sleeky,
    root: Sleeky.Event.Dsl.Event,
    tags: [
      Sleeky.Event.Dsl.Field
    ]
end
