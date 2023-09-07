defmodule Sleeky.Context.Dsl do
  @moduledoc false
  use Diesel.Dsl,
    otp_app: :sleeky,
    root: Sleeky.Context.Dsl.Context,
    tags: [
      Sleeky.Context.Dsl.Model,
      Sleeky.Context.Dsl.Authorization
    ]
end
