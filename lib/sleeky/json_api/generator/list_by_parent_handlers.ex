defmodule Sleeky.JsonApi.Generator.ListByParentHandlers do
  @moduledoc false
  @behaviour Diesel.Generator

  import Sleeky.Naming

  @impl true
  def generate(api, _) do
    for context <- api.contexts,
        model <- context.models(),
        %{name: :list} <- model.actions(),
        rel <- model.parents() do
      handler_module = Macro.camelize("json_api_list_by_#{rel.name}_handler")
      decoder_module = Macro.camelize("json_api_list_by_#{rel.name}_decoder")
      handler_module = Module.concat(model, handler_module)
      decoder_module = Module.concat(model, decoder_module)
      context_fun = String.to_atom("list_#{rel.inverse.name}_by_#{rel.name}")

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
              context = Map.merge(params, conn.assigns)

              params
              |> Map.fetch!(unquote(rel.name))
              |> unquote(context).unquote(context_fun)(context)
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
