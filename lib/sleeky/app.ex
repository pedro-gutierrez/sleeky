defmodule Sleeky.App do
  @moduledoc false
  use Diesel,
    otp_app: :sleeky,
    dsl: Sleeky.App.Dsl,
    parser: Sleeky.App.Parser,
    generators: [
      Sleeky.App.Generator.Migrate,
      Sleeky.App.Generator.Application
    ]

  defstruct [:name, :module, :repos, :endpoints, :features]
end
