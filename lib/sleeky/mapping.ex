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

  Works on single items and lists too
  """
  def map(mapping, data) do
    target_module = mapping.to()
    fields = mapping.fields()

    map(data, fields, target_module)
  end

  defp map(items, fields, target_module) when is_list(items) do
    with items when is_list(items) <-
           items
           |> Enum.reduce_while([], fn item, acc ->
             case map(item, fields, target_module) do
               {:ok, result} -> {:cont, [result | acc]}
               {:error, _} = error -> {:halt, error}
             end
           end),
         do: {:ok, Enum.reverse(items)}
  end

  defp map(item, fields, target_module) do
    fields
    |> Enum.reduce(%{}, fn field, acc ->
      value = Evaluate.evaluate(item, field.expression)
      Map.put(acc, field.name, value)
    end)
    |> target_module.new()
  end
end
