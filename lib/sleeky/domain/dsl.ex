defmodule Sleeky.Domain.Dsl do
  @moduledoc false
  use Diesel.Dsl,
    otp_app: :sleeky,
    root: Sleeky.Domain.Dsl.Domain,
    tags: [
      Sleeky.Domain.Dsl.Model,
      Sleeky.Domain.Dsl.Scopes
    ]
end
