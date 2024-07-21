defmodule Sleeky.View do
  @moduledoc false
  use Diesel,
    otp_app: :sleeky,
    overrides: [div: 2],
    generators: [
      Sleeky.View.Generator.Render,
      Sleeky.View.Generator.Source
    ]
end
