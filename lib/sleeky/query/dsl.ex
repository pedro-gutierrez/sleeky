defmodule Sleeky.Query.Dsl do
  @moduledoc false
  use Diesel.Dsl,
    otp_app: :sleeky,
    root: Sleeky.Query.Dsl.Query,
    tags: [
      Sleeky.Query.Dsl.Policy
    ]
end
