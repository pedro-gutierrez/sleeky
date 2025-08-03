defmodule Sleeky.Context.Dsl do
  @moduledoc false
  use Diesel.Dsl,
    otp_app: :sleeky,
    root: Sleeky.Context.Dsl.Context,
    tags: [
      Sleeky.Context.Dsl.Models,
      Sleeky.Context.Dsl.Scopes
    ]
end
