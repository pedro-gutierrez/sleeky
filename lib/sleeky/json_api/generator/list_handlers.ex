defmodule Sleeky.JsonApi.Generator.ListHandlers do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(api, _) do
    for context <- api.contexts, model <- context.models(), %{name: :list} <- model.actions() do
      handler_module = Module.concat(model, JsonApiListHandler)
      decoder_module = Module.concat(model, JsonApiListDecoder)

      context_fun = String.to_atom("list_#{model.plural()}")

      quote do
        defmodule unquote(handler_module) do
          use Plug.Builder

          import Sleeky.JsonApi.ConnHelper
          import Sleeky.JsonApi.Encoder
          import Sleeky.JsonApi.ErrorEncoder

          import unquote(decoder_module)

          plug(:execute)

          def execute(conn, _opts) do
            with {:ok, params} <- decode(conn.params) do
              params
              |> Map.merge(conn.assigns)
              |> unquote(context).unquote(context_fun)()
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
