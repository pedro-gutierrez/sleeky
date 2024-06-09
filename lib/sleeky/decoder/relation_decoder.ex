defmodule Sleeky.Decoder.RelationDecoder do
  @moduledoc """
  Validates relations in incoming json api requests
  """

  defmacro __using__(opts) do
    model = Keyword.fetch!(opts, :model)

    quote do
      import Validate.Validator

      def decode(%{value: id}) do
        case Ecto.UUID.cast(id) do
          {:ok, id} ->
            case unquote(model).fetch(id) do
              {:ok, model} -> success(model)
              {:error, :not_found} -> error("was not found")
            end

          _ ->
            error("not a valid uuid")
        end
      end
    end
  end
end
