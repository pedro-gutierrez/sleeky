defmodule Sleeky.Command.Dsl do
  @moduledoc false
  use Diesel.Dsl,
    otp_app: :sleeky,
    root: Sleeky.Command.Dsl.Command,
    tags: [
      Sleeky.Command.Dsl.Policy,
      Sleeky.Command.Dsl.Publish
    ]
end
