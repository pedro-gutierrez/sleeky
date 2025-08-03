defmodule Sleeky.Api.Generator.ReadHandlers do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(api, _) do
    for context <- api.contexts,
        entity <- context.entities(),
        %{name: :read} <- entity.actions() do
      handler_module = Module.concat(entity, ApiReadHandler)
      decoder_module = Module.concat(entity, ApiReadDecoder)

      context_fun = String.to_atom("read_#{entity.name()}")

      quote do
        defmodule unquote(handler_module) do
          use Plug.Builder

          import Sleeky.Api.ConnHelper
          import Sleeky.Api.ErrorEncoder
          import Sleeky.Api.Encoder

          import unquote(decoder_module)

          plug(:execute)

          def execute(conn, _opts) do
            with {:ok, params} <- decode(conn.params),
                 params <- Map.merge(params, conn.assigns),
                 {:ok, entity} <-
                   unquote(context).unquote(context_fun)(params.id, params) do
              entity
              |> encode()
              |> send_json(conn)
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
