defmodule Sleeky.Api.Generator.CreateHandlers do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(api, _) do
    for context <- api.contexts,
        entity <- context.entities(),
        %{name: :create} <- entity.actions() do
      handler_module(context, entity)
    end
  end

  defp handler_module(context, entity) do
    handler_module = Module.concat(entity, ApiCreateHandler)
    decoder_module = Module.concat(entity, ApiCreateDecoder)

    create_fun = String.to_atom("create_#{entity.name()}")

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
               {:ok, entity} <- unquote(context).unquote(create_fun)(params, conn.assigns) do
            entity
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
