defmodule Sleeky.Schema.Dsl do
  @moduledoc false
  use Diesel.Dsl,
    otp_app: :sleeky,
    root: :schema,
    tags: [:entity, :enum]
end
