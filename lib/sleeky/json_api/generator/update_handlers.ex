defmodule Sleeky.JsonApi.Generator.UpdateHandlers do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(api, _) do
    for context <- api.contexts, model <- context.models(), %{name: :update} <- model.actions() do
      handler_module(context, model)
    end
  end

  defp handler_module(context, model) do
    handler_module = Module.concat(model, JsonApiUpdateHandler)
    decoder_module = Module.concat(model, JsonApiUpdateDecoder)

    update_fun = String.to_atom("update_#{model.name()}")

    quote do
      defmodule unquote(handler_module) do
        use Plug.Builder

        import Sleeky.JsonApi.ConnHelper
        import Sleeky.JsonApi.Encoder
        import Sleeky.JsonApi.ErrorEncoder

        import unquote(decoder_module)

        plug(:execute)

        def execute(conn, _opts) do
          with {:ok, params} <- decode(conn.params),
               {:ok, model} <- unquote(model).fetch(params.id),
               {:ok, model} <- unquote(context).unquote(update_fun)(model, params, conn.assigns) do
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
