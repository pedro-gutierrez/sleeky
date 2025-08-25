defmodule Sleeky.App do
  @moduledoc false
  use Diesel,
    otp_app: :sleeky,
    dsl: Sleeky.App.Dsl,
    parser: Sleeky.App.Parser,
    generators: [
      Sleeky.App.Generator.Migrate,
      Sleeky.App.Generator.Application,
      Sleeky.App.Generator.Roles
    ]

  defstruct [:name, :roles, :module, :repos, :endpoints, :features]
end
