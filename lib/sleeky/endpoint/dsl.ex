defmodule Sleeky.Endpoint.Dsl do
  @moduledoc false
  use Diesel.Dsl,
    otp_app: :sleeky,
    tags: [
      Sleeky.Endpoint.Dsl.Mount
    ]
end
