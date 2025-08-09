defmodule Sleeky.Projection.Dsl do
  @moduledoc false
  use Diesel.Dsl,
    otp_app: :sleeky,
    root: Sleeky.Projection.Dsl.Projection,
    tags: [
      Sleeky.Projection.Dsl.Field
    ]
end
