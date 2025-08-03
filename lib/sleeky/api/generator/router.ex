defmodule Sleeky.Api.Generator.Router do
  @moduledoc false
  @behaviour Diesel.Generator

  import Sleeky.Naming

  @impl true
  def generate(api, _) do
    conn = var(:conn)

    routes = api |> routes() |> List.flatten()
    plugs = plugs(api)

    quote do
      defmodule Router do
        @moduledoc false
        use Plug.Router
        import Sleeky.Api.ConnHelper

        plug(:match)

        plug(Plug.Parsers,
          parsers: [:urlencoded, :multipart, :json],
          pass: ["*/*"],
          json_decoder: Jason
        )

        unquote_splicing(plugs)

        unquote_splicing(routes)

        plug(:dispatch)

        @no_route_error %{reason: "no such route"}

        match _ do
          send_json(@no_route_error, unquote(conn), status: 404)
        end
      end
    end
  end

  defp plugs(api) do
    for plug <- api.plugs do
      quote do
        plug unquote(plug)
      end
    end
  end

  @supported_actions [:create, :update, :read, :list, :delete]

  defp routes(api) do
    default_routes(api) ++ list_by_parent_routes(api)
  end

  defp default_routes(api) do
    for context <- api.contexts,
        entity <- context.entities(),
        action when action.name in @supported_actions <- entity.actions() do
      route(context, entity, action.name)
    end
  end

  defp list_by_parent_routes(api) do
    for context <- api.contexts,
        entity <- context.entities(),
        action when action.name == :list <- entity.actions(),
        rel <- entity.parents() do
      handler = Macro.camelize("api_list_by_#{rel.name}_handler")
      handler = Module.concat(entity, handler)
      path = relation_path(context, rel.target.module, rel.inverse)

      quote do
        get(unquote(path), to: unquote(handler))
      end
    end
  end

  defp route(context, entity, action) do
    handler = handler_module(entity, action)
    method = method(action)
    path = path(context, entity, action)

    quote do
      unquote(method)(unquote(path), to: unquote(handler))
    end
  end

  defp method(:read), do: :get
  defp method(:list), do: :get
  defp method(:create), do: :post
  defp method(:update), do: :patch
  defp method(:delete), do: :delete

  defp handler_module(entity, action) do
    module_name = Macro.camelize("api_#{action}_handler")

    Module.concat(entity, module_name)
  end

  defp path(context, entity, action) do
    case action do
      :read -> item_path(context, entity)
      :list -> collection_path(context, entity)
      :create -> collection_path(context, entity)
      :update -> item_path(context, entity)
      :delete -> item_path(context, entity)
    end
  end

  defp collection_path(context, entity), do: "/#{context.name()}/#{entity.plural()}"

  defp relation_path(context, entity, rel),
    do: "/#{context.name()}/#{entity.plural()}/:id/#{rel.name}"

  defp item_path(context, entity), do: collection_path(context, entity) <> "/:id"
end
