defmodule Sleeky.Api.Generator.UpdateHandlers do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(api, _) do
    for feature <- api.features, model <- feature.models(), %{name: :update} <- model.actions() do
      handler_module(feature, model)
    end
  end

  defp handler_module(feature, model) do
    handler_module = Module.concat(model, ApiUpdateHandler)
    decoder_module = Module.concat(model, ApiUpdateDecoder)

    feature_fun = String.to_atom("update_#{model.name()}")

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
               {:ok, model} <- unquote(model).fetch(params.id),
               {:ok, model} <- unquote(feature).unquote(feature_fun)(model, params, conn.assigns) do
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
