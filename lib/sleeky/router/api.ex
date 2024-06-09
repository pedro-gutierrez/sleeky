defmodule Sleeky.Router.Api do
  @moduledoc false

  import Sleeky.Naming

  def routes(router, contexts) do
    for context <- contexts, model <- context.models(), action <- model.actions() do
      routes(router, context, model, action)
    end
  end

  def handlers(router, contexts) do
    for context <- contexts, model <- context.models(), action <- model.actions() do
      handlers(router, context, model, action)
    end
  end

  defp routes(router, context, model, action) do
    handler = handler_module(router, context, model, action)
    method = method(action.name)
    path = path(context, model, action)

    quote do
      unquote(method)(unquote(path), to: unquote(handler))
    end
  end

  defp method(:read), do: :get
  defp method(:list), do: :get
  defp method(:create), do: :post
  defp method(:update), do: :patch
  defp method(:delete), do: :delete

  defp handler_module(router, context, model, action) do
    context = context |> Module.split() |> List.last()
    model = model |> Module.split() |> List.last()
    action = action.name |> to_string() |> Macro.camelize()

    Module.concat([router, Api, context, model, action])
  end

  defp path(context, model, action) do
    case action.name do
      :read -> item_path(context, model)
      :list -> collection_path(context, model)
      :create -> collection_path(context, model)
      :update -> item_path(context, model)
      :delete -> item_path(context, model)
    end
  end

  defp collection_path(context, model), do: "/#{context.name}/#{model.plural()}"
  defp item_path(context, model), do: collection_path(context, model) <> "/:id"

  defp handlers(router, context, model, %{name: :create} = action) do
    params_var = var(:params)
    handler_module = handler_module(router, context, model, action)
    context_action = String.to_atom("create_#{model.name()}")

    quote do
      defmodule unquote(handler_module) do
        use Plug.Builder
        import Sleeky.Router.Json

        plug(:check_content_type)
        plug(:execute)

        alias __MODULE__.Validator
        alias __MODULE__.Renderer

        defmodule Validator do
          def validate(_params) do
            {:ok, %{}}
          end
        end

        defmodule Renderer do
          def render(_model) do
            %{}
          end
        end

        def execute(conn, opts) do
          with {:ok, unquote(params_var)} <- Validator.validate(conn.params),
               {:ok, model} <-
                 unquote(context).unquote(context_action)(
                   unquote(params_var),
                   conn.assigns
                 ),
               {:ok, body} <- Renderer.render(model) do
            send_json(conn, body, status: 201)
          else
            {:error, _} = error ->
              send_json(conn, error)
          end
        end
      end
    end
  end

  defp handlers(router, context, model, action) do
    module_name = handler_module(router, context, model, action)

    quote do
      defmodule unquote(module_name) do
        use Plug.Builder
        import Sleeky.Router.Json

        plug(:execute)

        def execute(conn, _opts) do
          send_json(conn, %{})
        end
      end
    end
  end
end
