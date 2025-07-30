defmodule Sleeky.Ui.Route.Dsl do
  @moduledoc false
  use Diesel.Dsl,
    otp_app: :sleeky,
    root: Sleeky.Ui.Route.Dsl.Route,
    tags: [
      Sleeky.Ui.Route.Dsl.View
    ]
end
