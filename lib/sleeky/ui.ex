defmodule Sleeky.Ui do
  @moduledoc false
  use Diesel,
    otp_app: :sleeky,
    dsl: Sleeky.Ui.Dsl,
    overrides: [binding: 1],
    generators: [
      Sleeky.Ui.Generators.Router,
      Sleeky.Ui.Generators.Js
    ]
end
