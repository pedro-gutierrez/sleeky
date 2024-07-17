defmodule Sleeky.JsonApi.Generator.CreateHandlers do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(api, _) do
    for context <- api.contexts, model <- context.models(), %{name: :create} <- model.actions() do
      handler_module(context, model)
    end
  end

  defp handler_module(context, model) do
    handler_module = Module.concat(model, JsonApiCreateHandler)
    decoder_module = Module.concat(model, JsonApiCreateDecoder)

    create_fun = String.to_atom("create_#{model.name()}")

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
               {:ok, model} <- unquote(context).unquote(create_fun)(params, conn.assigns) do
            model
            |> encode()
            |> send_json(conn, status: 201)
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
