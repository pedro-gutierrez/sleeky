defmodule Bee.Rest.Router do
  @moduledoc false

  import Bee.Inspector

  alias Bee.Entity.Action
  alias Bee.Rest.Handlers

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
    [
      standard_routes(entity, rest)
    ]
  end

  defp standard_routes(entity, rest) do
    for action <- entity.actions do
      handler = Handlers.module_name(rest, entity, action)
      method = http_method(action)
      path = http_path(action)

      quote do
        unquote(method)(unquote(path), to: unquote(handler))
      end
    end
  end

  def http_method(:read), do: :get
  def http_method(:list), do: :get
  def http_method(:create), do: :post
  def http_method(:update), do: :patch
  def http_method(:delete), do: :delete
  def http_method(%Action{} = action), do: http_method(action.name)

  defp http_path(%Action{} = action) do
    case action.name do
      :read -> resource_http_path(action.entity)
      :list -> collection_http_path(action.entity)
      :create -> collection_http_path(action.entity)
      :update -> resource_http_path(action.entity)
      :delete -> resource_http_path(action.entity)
    end
  end

  defp resource_http_path(entity), do: "/#{entity.plural}/:id"
  defp collection_http_path(entity), do: "/#{entity.plural}"
end