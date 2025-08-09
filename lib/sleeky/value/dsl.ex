defmodule Sleeky.Value.Dsl do
  @moduledoc false
  use Diesel.Dsl,
    otp_app: :sleeky,
    root: Sleeky.Value.Dsl.Value,
    tags: [
      Sleeky.Value.Dsl.Field
    ]
end
