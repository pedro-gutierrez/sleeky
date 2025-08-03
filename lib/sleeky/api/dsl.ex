defmodule Sleeky.Api.Dsl do
  @moduledoc false
  use Diesel.Dsl,
    otp_app: :sleeky,
    root: Sleeky.Api.Dsl.Api,
    tags: [
      Sleeky.Api.Dsl.Contexts,
      Sleeky.Api.Dsl.Plugs
    ]
end
