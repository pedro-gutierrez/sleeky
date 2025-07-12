defmodule Sleeky.Scopes do
  @moduledoc false

  use Diesel,
    otp_app: :sleeky,
    dsl: Sleeky.Scopes.Dsl,
    generators: [
      Sleeky.Scopes.Generator.Metadata
    ],
    parsers: [
      Sleeky.Scopes.Parser
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
