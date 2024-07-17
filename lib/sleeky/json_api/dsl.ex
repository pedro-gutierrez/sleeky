defmodule Sleeky.JsonApi.Dsl do
  @moduledoc false
  use Diesel.Dsl,
    otp_app: :sleeky,
    root: Sleeky.JsonApi.Dsl.JsonApi,
    tags: [
      Sleeky.JsonApi.Dsl.Context,
      Sleeky.JsonApi.Dsl.Plugs
    ]
end
