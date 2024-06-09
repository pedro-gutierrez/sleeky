defmodule Sleeky.JsonApi.Generator.ReadHandlers do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(api, _) do
    for context <- api.contexts, model <- context.models(), %{name: :read} <- model.actions() do
      handler_module = Module.concat(model, JsonApiReadHandler)
      decoder_module = Module.concat(model, JsonApiReadDecoder)

      context_fun = String.to_atom("read_#{model.name()}")

      quote do
        defmodule unquote(handler_module) do
          use Plug.Builder

          import Sleeky.JsonApi.ConnHelper
          import Sleeky.JsonApi.ErrorEncoder
          import Sleeky.JsonApi.Encoder

          import unquote(decoder_module)

          plug(:execute)

          def execute(conn, _opts) do
            with {:ok, params} <- decode(conn.params),
                 params <- Map.merge(params, conn.assigns),
                 {:ok, model} <-
                   unquote(context).unquote(context_fun)(params.id, params) do
              model
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
