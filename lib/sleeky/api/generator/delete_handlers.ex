defmodule Sleeky.Api.Generator.DeleteHandlers do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(api, _) do
    for domain <- api.domains, model <- domain.models(), %{name: :delete} <- model.actions() do
      handler_module = Module.concat(model, ApiDeleteHandler)
      decoder_module = Module.concat(model, ApiDeleteDecoder)

      domain_fun = String.to_atom("delete_#{model.name()}")

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
                 :ok <- unquote(domain).unquote(domain_fun)(model, conn.assigns) do
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
