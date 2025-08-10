defmodule Sleeky.Event do
  @moduledoc """
  A DSL to define domain events in the context of DDD and Event Sourcing
  """

  use Diesel,
    otp_app: :sleeky,
    dsl: Sleeky.Event.Dsl,
    parser: Sleeky.Event.Parser,
    generators: [
      Sleeky.Event.Generator.EctoSchema,
      Sleeky.Event.Generator.Metadata,
      Sleeky.Event.Generator.Serialize
    ]

  defmodule Field do
    @moduledoc false
    defstruct [:name, :type, :required, :default, :allowed_values]
  end

  defstruct [:name, :version, :fields, :feature]
end
