defmodule Sleeky.Mapping do
  @moduledoc """
  A DSL to define mappings between different data structures
  """

  use Diesel,
    otp_app: :sleeky,
    dsl: Sleeky.Mapping.Dsl,
    parser: Sleeky.Mapping.Parser,
    generators: [
      Sleeky.Mapping.Generator.Metadata,
      Sleeky.Mapping.Generator.Transform
    ]

  defmodule Field do
    @moduledoc false
    defstruct [:name, :expression]
  end

  defstruct [:name, :feature, :from, :to, :fields]

  alias Sleeky.Evaluate

  @doc """
  Applies the mapping to the given data
  """
  def map(mapping, data) do
    target_module = mapping.to()

    mapping.fields()
    |> Enum.reduce(%{}, fn field, acc ->
      value = Evaluate.evaluate(data, field.expression)
      Map.put(acc, field.name, value)
    end)
    |> target_module.new()
  end
end
