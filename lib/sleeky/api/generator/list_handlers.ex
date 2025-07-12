defmodule Sleeky.Api.Generator.ListHandlers do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(api, _) do
    for context <- api.contexts, model <- context.models(), %{name: :list} <- model.actions() do
      handler_module = Module.concat(model, ApiListHandler)
      decoder_module = Module.concat(model, ApiListDecoder)

      context_fun = String.to_atom("list_#{model.plural()}")

      quote do
        defmodule unquote(handler_module) do
          use Plug.Builder

          import Sleeky.Api.ConnHelper
          import Sleeky.Api.Encoder
          import Sleeky.Api.ErrorEncoder

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
