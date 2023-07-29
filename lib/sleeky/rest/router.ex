defmodule Sleeky.Rest.Router do
  @moduledoc false

  import Sleeky.Inspector
  alias Sleeky.Rest.Handlers

  def ast(rest, schema) do
    router = module(rest, Router)
    helper = module(rest, RouterHelper)
    openapi = module(rest, OpenApi)
    telemetry_prefix = module_parts(router)

    routes =
      schema.entities()
      |> Enum.map(&routes(&1, rest))
      |> flatten()

    conn = var(:conn)

    quote do
      defmodule unquote(router) do
        @moduledoc false
        use Plug.Router
        import unquote(helper)

        plug(:match)
        plug(Plug.Telemetry, event_prefix: unquote(telemetry_prefix))

        plug(Plug.Parsers,
          parsers: [:urlencoded, :multipart, :json],
          pass: ["*/*"],
          json_decoder: Jason
        )

        plug(:dispatch)

        unquote_splicing(routes)

        get("/openapi.json", to: unquote(openapi))

        match _ do
          send_json(unquote(conn), %{reason: :no_such_route}, 404)
        end
      end
    end
  end

  defp routes(entity, rest) do
    for generator <- Handlers.generators() do
      generator.routes(entity, rest)
    end
  end
end
