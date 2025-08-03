defmodule Sleeky.Api.Generator.DeleteHandlers do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(api, _) do
    for context <- api.contexts,
        entity <- context.entities(),
        %{name: :delete} <- entity.actions() do
      handler_module = Module.concat(entity, ApiDeleteHandler)
      decoder_module = Module.concat(entity, ApiDeleteDecoder)

      context_fun = String.to_atom("delete_#{entity.name()}")

      quote do
        defmodule unquote(handler_module) do
          use Plug.Builder

          import Sleeky.Api.ConnHelper
          import Sleeky.Api.Encoder
          import Sleeky.Api.ErrorEncoder

          import unquote(decoder_module)

          plug(:execute)

          def execute(conn, _opts) do
            with {:ok, params} <- decode(conn.params),
                 {:ok, entity} <- unquote(entity).fetch(params.id),
                 :ok <- unquote(context).unquote(context_fun)(entity, conn.assigns) do
              send_json(%{}, conn, status: 204)
            else
              {:error, errors} ->
                errors
                |> encode_errors()
                |> send_json(conn)
            end
          end
        end
      end
    end
  end
end
