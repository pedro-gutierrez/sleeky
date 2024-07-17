defmodule Sleeky.Decoder.PairsDecoder do
  @moduledoc """
  A generic validator that parses string params into maps, using a dsl
  """

  defmacro __using__(opts) do
    rules = Keyword.fetch!(opts, :rules)
    field_names = rules |> Map.keys() |> Enum.map(&String.to_existing_atom/1)

    quote do
      import Validate.Validator

      @rules unquote(Macro.escape(rules))
      @field_names unquote(field_names)

      def decode(%{value: value}) do
        value =
          value
          |> String.split(",")
          |> Enum.map(&String.split(&1, ":"))
          |> Enum.map(&List.to_tuple/1)
          |> Enum.into(%{})

        case Validate.validate(value, @rules) do
          {:ok, value} ->
            @field_names
            |> Enum.reduce(%{}, fn name, acc ->
              case Map.get(value, to_string(name)) do
                nil -> acc
                value -> Map.put(acc, name, value)
              end
            end)
            |> success()

          {:error, _} ->
            error("not supported")
        end
      end
    end
  end
end
