defmodule Sleeky.Ui.Action.Dsl do
  @moduledoc false
  use Diesel.Dsl,
    otp_app: :sleeky,
    root: Sleeky.Ui.Action.Dsl.Action,
    tags: [
      Sleeky.Ui.Action.Dsl.On
    ]
end
