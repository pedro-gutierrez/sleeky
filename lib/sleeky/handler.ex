defmodule Sleeky.Handler do
  @moduledoc false
  use Diesel,
    otp_app: :sleeky,
    dsl: Sleeky.Handler.Dsl,
    generators: []

  defstruct [:feature]
end
