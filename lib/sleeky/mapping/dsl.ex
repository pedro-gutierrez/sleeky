defmodule Sleeky.Mapping.Dsl do
  @moduledoc false
  use Diesel.Dsl,
    otp_app: :sleeky,
    root: Sleeky.Mapping.Dsl.Mapping,
    tags: [
      Sleeky.Mapping.Dsl.Field
    ]
end
