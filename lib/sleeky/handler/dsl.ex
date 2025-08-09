defmodule Sleeky.Handler.Dsl do
  @moduledoc false
  use Diesel.Dsl,
    otp_app: :sleeky,
    root: Sleeky.Handler.Dsl.Handler,
    tags: [
      Sleeky.Handler.Dsl.Emits
    ]
end
