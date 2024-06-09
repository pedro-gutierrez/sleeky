defmodule Sleeky.Endpoint do
  @moduledoc """
  An endpoint wraps a Bandit listener and a router
  """
  use Diesel,
    otp_app: :sleeky,
    generators: [
      Sleeky.Endpoint.Generator.Router,
      Sleeky.Endpoint.Generator.Supervisor
    ]

  defstruct [:mounts]

  defmodule Mount do
    @moduledoc false
    defstruct [:path, :router]
  end
end
