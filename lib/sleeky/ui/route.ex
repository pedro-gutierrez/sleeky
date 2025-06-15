defmodule Sleeky.Ui.Route do
  @moduledoc false
  use Diesel,
    otp_app: :sleeky,
    dsl: Sleeky.Ui.Route.Dsl,
    generators: [
      Sleeky.Ui.Route.Generator.Handler,
      Sleeky.Ui.Route.Generator.Metadata
    ]

  defstruct [:path, :method, :action, :views]
end
