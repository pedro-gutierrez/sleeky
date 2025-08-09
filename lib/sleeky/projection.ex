defmodule Sleeky.Projection do
  @moduledoc """
  A DSL to define projections for read-only data representations
  """

  use Diesel,
    otp_app: :sleeky,
    dsl: Sleeky.Projection.Dsl,
    parser: Sleeky.Projection.Parser,
    generators: [
      Sleeky.Projection.Generator.EctoSchema,
      Sleeky.Projection.Generator.Metadata,
      Sleeky.Projection.Generator.Changeset
    ]

  defmodule Field do
    @moduledoc false
    defstruct [:name, :type, :required, :default, :allowed_values]
  end

  defstruct [:fields]
end
