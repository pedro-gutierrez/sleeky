defmodule Sleeky.Ui.View do
  @moduledoc false
  use Diesel,
    otp_app: :sleeky,
    overrides: [div: 2],
    generators: [
      Sleeky.Ui.View.Generator.Render,
      Sleeky.Ui.View.Generator.Source
    ]
end
