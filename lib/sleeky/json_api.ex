defmodule Sleeky.JsonApi do
  @moduledoc """
  Builds a json api for your domain
  """
  use Diesel,
    otp_app: :sleeky,
    dsl: Sleeky.JsonApi.Dsl,
    parsers: [
      Sleeky.JsonApi.Parser
    ],
    generators: [
      Sleeky.JsonApi.Generator.Validators
    ]

  defstruct [:contexts]
end
