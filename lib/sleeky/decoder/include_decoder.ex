defmodule Sleeky.Decoder.IncludeDecoder do
  @moduledoc """
  Validates 'include' params and transforms them into Ecto preloads
  """

  defmacro __using__(opts) do
    model = Keyword.fetch!(opts, :model)

    quote do
      import Validate.Validator

      def decode(%{value: includes}) do
        includes
        |> String.split(",")
        |> Enum.reduce_while([], fn field, acc ->
          case unquote(model).field(field) do
            {:ok, field} -> {:cont, [field.name | acc]}
            {:error, _} -> {:halt, "no such field #{field}"}
          end
        end)
        |> then(fn
          preloads when is_list(preloads) -> preloads |> Enum.reverse() |> success()
          error when is_binary(error) -> error(error)
        end)
      end
    end
  end
end
