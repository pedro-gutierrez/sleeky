defmodule Bee.Rest.Handlers.Helpers do
  @moduledoc false
  import Bee.Inspector

  alias Bee.Entity.Action

  def handler(rest, entity, action, body) when is_list(body) do
    module_name = module_name(rest, entity, action)
    helper = module(rest, RouterHelper)

    quote do
      defmodule unquote(module_name) do
        use Plug.Builder
        import unquote(helper)

        plug(:handle)

        unquote_splicing(body)
      end
    end
  end

  def handler(rest, entity, action, body) do
    handler(rest, entity, action, [body])
  end

  def module_name(rest, entity, %Action{} = action) do
    module_name(rest, entity, action.name)
  end

  def module_name(rest, entity, action) do
    module([rest, Handler, entity.name(), action])
  end

  def required_id_arg do
    conn = var(:conn)
    args = var(:args)

    quote do
      {:ok, unquote(args)} <-
        unquote(conn) |> cast_param("id", :id, :required) |> as(:id, unquote(args))
    end
  end

  def pagination_args do
    conn = var(:conn)

    quote do
      {:ok, unquote(conn)} <- with_pagination(unquote(conn))
    end
  end
end
