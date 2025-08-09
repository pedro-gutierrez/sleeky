defmodule Sleeky.Command do
  @moduledoc false
  use Diesel,
    otp_app: :sleeky,
    dsl: Sleeky.Command.Dsl,
    generators: [
      Sleeky.Command.Generator.Allow,
      Sleeky.Command.Generator.Metadata
    ]

  defstruct [:name, :feature, :params, :policies, :handler, :atomic?]

  defmodule Policy do
    @moduledoc false
    defstruct [:role, :scope]
  end
end
