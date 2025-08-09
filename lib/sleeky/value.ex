defmodule Sleeky.Value do
  @moduledoc """
  A dsl to define values in the context of DDD
  """

  use Diesel,
    otp_app: :sleeky,
    dsl: Sleeky.Value.Dsl,
    generators: [
      Sleeky.Value.Generator.EctoSchema,
      Sleeky.Value.Generator.Changeset,
      Sleeky.Value.Generator.Validate
    ]

  defmodule Field do
    @moduledoc false
    defstruct [:name, :type, :required, :default, :allowed_values]
  end

  defstruct [:fields]
end
