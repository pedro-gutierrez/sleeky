defmodule Sleeky.Html do
  @moduledoc false
  use Diesel,
    otp_app: :sleeky,
    dsl: Sleeky.Html.Dsl,
    overrides: [div: 2],
    compilation_flags: [:strip_root],
    generators: [
      Sleeky.Html.Generator.Render,
      Sleeky.Html.Generator.Source
    ]
end
