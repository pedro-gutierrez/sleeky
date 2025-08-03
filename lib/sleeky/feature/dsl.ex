defmodule Sleeky.Feature.Dsl do
  @moduledoc false
  use Diesel.Dsl,
    otp_app: :sleeky,
    root: Sleeky.Feature.Dsl.Feature,
    tags: [
      Sleeky.Feature.Dsl.Feature,
      Sleeky.Feature.Dsl.Models,
      Sleeky.Feature.Dsl.Scopes
    ]
end
