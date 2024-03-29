defmodule Sleeky.Authorization do
  @moduledoc false

  use Diesel,
    otp_app: :sleeky,
    dsl: Sleeky.Authorization.Dsl,
    generators: [
      Sleeky.Authorization.Generator.Metadata
    ],
    parsers: [
      Sleeky.Authorization.Parser
    ]

  defmodule Scope do
    @moduledoc false
    defstruct [:name, :debug, :expression]
  end

  defmodule Expression do
    @moduledoc false
    defstruct [:op, :args]
  end

  defstruct [:roles, scopes: %{}]
end
