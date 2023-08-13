defmodule Sleeky.Rest.Handlers.Aggregates do
  @moduledoc false

  alias Sleeky.Entity.Relation
  import Sleeky.Inspector
  import Sleeky.Rest.Handlers.Helpers

  def handlers(entity, rest) do
    for child <- entity.children() do
      if list?(child.target.module) do
        handler(child, rest)
      else
        nil
      end
    end
  end

  def routes(entity, rest) do
    for child <- entity.children() do
      if list?(child.target.module) do
        route(child, rest)
      else
        nil
      end
    end
  end

  defp route(%Relation{} = rel, rest) do
    method = :get
    path = "/#{rel.entity.plural}/:id/#{rel.name}/aggregate"
    action = action(rel)
    handler = module_name(rest, rel.entity, action)

    quote do
      unquote(method)(unquote(path), to: unquote(handler))
    end
  end

  defp action(rel) do
    module(Aggregate, Inflex.camelize(rel.name))
  end

  defp handler(%Relation{} = rel, rest) do
    conn = var(:conn)
    args = var(:args)
    entity = rel.entity
    action = action(rel)

    preconditions = [
      required_primary_key_arg(entity),
      api_call(rel)
    ]

    body =
      quote do
        def handle(unquote(conn), _opts) do
          unquote(args) = %{}

          with unquote_splicing(flatten(preconditions)) do
            send_json(unquote(conn), data, 200)
          else
            {:error, reason} -> send_error(unquote(conn), reason)
          end
        end
      end

    handler(rest, entity, action, body)
  end

  defp api_call(rel) do
    conn = var(:conn)
    args = var(:args)
    entity = rel.target.module
    fun_name = function_name(:aggregate_by, rel.inverse.name)

    quote do
      {:ok, data} <-
        unquote(entity).unquote(fun_name)(
          unquote(args).id,
          unquote(conn).assigns
        )
    end
  end

  def list?(entity) do
    Enum.find(entity.actions, &(&1.name == :list))
  end
end
