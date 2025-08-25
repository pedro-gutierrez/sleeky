defmodule Sleeky.Flow.Dsl do
  @moduledoc false
  use Diesel.Dsl,
    otp_app: :sleeky,
    root: Sleeky.Flow.Dsl.Flow,
    tags: [
      Sleeky.Flow.Dsl.Steps
    ]
end
