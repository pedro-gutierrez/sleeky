defmodule Sleeky.App.Dsl do
  @moduledoc false
  use Diesel.Dsl,
    otp_app: :sleeky,
    root: Sleeky.App.Dsl.App,
    tags: [
      Sleeky.App.Dsl.Repos,
      Sleeky.App.Dsl.Endpoints,
      Sleeky.App.Dsl.Contexts
    ]
end
