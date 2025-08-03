defmodule Sleeky.Decoder.RelationDecoder do
  @moduledoc """
  Validates relations in incoming json api requests
  """

  defmacro __using__(opts) do
    entity = Keyword.fetch!(opts, :entity)

    quote do
      import Validate.Validator

      def decode(%{value: id}) do
        case Ecto.UUID.cast(id) do
          {:ok, id} ->
            case unquote(entity).fetch(id) do
              {:ok, entity} -> success(entity)
              {:error, :not_found} -> error("was not found")
            end

          _ ->
            error("not a valid uuid")
        end
      end
    end
  end
end
