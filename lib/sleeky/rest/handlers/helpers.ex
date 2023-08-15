defmodule Sleeky.Rest.Handlers.Helpers do
  @moduledoc false
  import Sleeky.Inspector

  alias Sleeky.Entity.Action

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

  def required_primary_key_arg(entity) do
    conn = var(:conn)
    args = var(:args)
    pk = entity.primary_key()
    field = pk.name
    kind = pk.kind
    param_name = to_string(field)

    quote do
      {:ok, unquote(args)} <-
        unquote(conn)
        |> cast_param(unquote(param_name), unquote(kind), :required)
        |> as(unquote(field), unquote(args))
    end
  end

  def pagination_args do
    conn = var(:conn)

    quote do
      {:ok, unquote(conn)} <- with_pagination(unquote(conn))
    end
  end

  def query_arg do
    conn = var(:conn)

    quote do
      {:ok, unquote(conn)} <- with_query(unquote(conn))
    end
  end
end
