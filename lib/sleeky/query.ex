defmodule Sleeky.Query do
  @moduledoc false
  use Diesel,
    otp_app: :sleeky,
    dsl: Sleeky.Query.Dsl,
    parser: Sleeky.Query.Parser,
    generators: [
      Sleeky.Query.Generator.Allow,
      Sleeky.Query.Generator.Metadata,
      Sleeky.Query.Generator.Execute
    ]

  defstruct [:name, :feature, :params, :returns, :policies, :handler, :limit, :many]

  defmodule Policy do
    @moduledoc false
    defstruct [:role, :scope]
  end
end
