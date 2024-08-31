defmodule Sleeky.Ui.Dsl do
  @moduledoc false
  use Diesel.Dsl,
    otp_app: :sleeky,
    tags: [
      Sleeky.Ui.Dsl.Context,
      Sleeky.Ui.Dsl.Page
    ]
end
